// mlx xpm
// by ol

#include <stdlib.h>
#include <stdio.h>
#include <sys/mman.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>

#include "mlx.h"

typedef struct  s_xpm_col
{
  int           name;
  int           col;
} t_xpm_col;


struct  s_col_name
{
  char  *name;
  int   color;
};

//extern struct s_col_name mlx_col_name[];
#include "mlx_rgb.c"


#define	RETURN	{ if (colors) free(colors); if (tab) free(tab); \
		  if (colors_direct) free(colors_direct); \
                  if (img) mlx_destroy_image(xvar, img);   \
                  return ((void *)0); }




//
// str 2 wordtab & co

int	mlx_int_str_str(char *str,char *find,int len)
{
  int	len_f;
  int	pos;
  char	*s;
  char	*f;

  len_f = strlen(find);
  if (len_f>len)
    return (-1);
  pos = 0;
  while (*(str+len_f-1))
    {
      s = str;
      f = find;
      while (*(f++) == *(s++))
        if (!*f)
          return (pos);
      str ++;
      pos ++;
    }
  return (-1);
}



int	mlx_int_str_str_cote(char *str,char *find,int len)
{
  int	len_f;
  int	pos;
  char	*s;
  char	*f;
  int	cote;

  len_f = strlen(find);
  if (len_f>len)
    return (-1);
  cote = 0;
  pos = 0;
  while (*(str+len_f-1))
    {
      if (*str=='"')
	cote = 1-cote;
      if (!cote)
	{
	  s = str;
	  f = find;
	  while (*(f++) == *(s++))
	    if (!*f)
	      return (pos);
	}
      str ++;
      pos ++;
    }
  return (-1);
}


char	**mlx_int_str_to_wordtab(char *str)
{
  char	**tab;
  int	pos;
  int	nb_word;
  int	len;

  len = strlen(str);
  nb_word = 0;
  pos = 0;
  while (pos<len)
  {
    while (*(str+pos)==' ' || *(str+pos)=='\t')
      pos ++;
    if (*(str+pos))
      nb_word ++;
    while (*(str+pos) && *(str+pos)!=' ' && *(str+pos)!='\t')
      pos ++;
  }
  if (!(tab = malloc((1+nb_word)*sizeof(*tab))))
    return ((char **)0);
  nb_word = 0;
  pos = 0;
  while (pos<len)
    {
      while (*(str+pos)==' ' || *(str+pos)=='\t')
	{
	  *(str+pos) = 0;
	  pos ++;
	}
      if (*(str+pos))
	{
	  tab[nb_word] = str+pos;
	  nb_word ++;
	}
      while (*(str+pos) && *(str+pos)!=' ' && *(str+pos)!='\t')
	pos ++;
    }
  tab[nb_word] = 0;
  return (tab);
}


// back to mlx_xpm



char	*mlx_int_get_line(char *ptr,int *pos,int size)
{
  int	pos2;
  int	pos3;
  int	pos4;

  if ((pos2 = mlx_int_str_str(ptr+*pos,"\"",size-*pos))==-1)
    return ((char *)0);
  if ((pos3 = mlx_int_str_str(ptr+*pos+pos2+1,"\"",size-*pos-pos2-1))==-1)
    return ((char *)0);
  *(ptr+*pos+pos2) = 0;
  *(ptr+*pos+pos2+1+pos3) = 0;
  pos4 = *pos+pos2+1;
  *pos += pos2+pos3+2;
  return (ptr+pos4);
}



char	*mlx_int_static_line(char **xpm_data,int *pos,int size)
{
  static char	*copy = 0;
  static int	len = 0;
  int		len2;
  char		*str;

  str = xpm_data[(*pos)++];
  if ((len2 = strlen(str))>len)
    {
      if (copy)
	free(copy);
      if (!(copy = malloc(len2+1)))
	return ((char *)0);
      len = len2;
    }
  /* strcpy(copy,str); */
  strlcpy(copy, str, len2+1);
  return (copy);
}


int	mlx_int_get_col_name(char *str,int size)
{
  int	result;

  result = 0;
  while (size--)
    result = (result<<8)+*(str++);
  return (result);
}

int	mlx_int_get_text_rgb(char *name, char *end)
{
  int	i;
  char	buff[64];

  if (*name == '#')
    return (strtol(name+1,0,16));
  if (end)
    {
      snprintf(buff, 64, "%s %s", name, end);
      name = buff;
    }
  i = 0;
  while (mlx_col_name[i].name)
    {
      if (!strcasecmp(mlx_col_name[i].name, name))
	return (mlx_col_name[i].color);
      i ++;
    }
  return (0);
}


void	mlx_int_xpm_set_pixel(char *data, int opp, int col, int x)
{
  *((unsigned int *)(data+4*x)) = col;
}


void	*mlx_int_parse_xpm(void *xvar,void *info,int info_size,char *(*f)(), int *width, int *height)
{
  int	pos;
  char	*line;
  char	**tab;
  char	*data;
  char	*clip_data;
  int	nc;
  int	opp;
  int   sl;
  int   endian;
  int	cpp;
  int	col;
  int	rgb_col;
  int	col_name;
  int	method;
  int	x;
  int	i;
  int	j;
  void	*img;
  t_xpm_col	*colors;
  int		*colors_direct;

  colors = 0;
  colors_direct = 0;
  img = 0;
  tab = 0;
  pos = 0;
  if (!(line = f(info,&pos,info_size)) ||
      !(tab = mlx_int_str_to_wordtab(line)) || !(*width = atoi(tab[0])) ||
      !(*height = atoi(tab[1])) || !(nc = atoi(tab[2])) ||
      !(cpp = atoi(tab[3])) )
    RETURN;
  free(tab);
  tab = 0;

  method = 0;
  if (cpp<=2)
    {
      method = 1;
      if (!(colors_direct = malloc((cpp==2?65536:256)*sizeof(int))))
	RETURN;
    }
  else
    if (!(colors = malloc(nc*sizeof(*colors))))
      RETURN;

  clip_data = 0;

  i = nc;
  while (i--)
    {
      if (!(line = f(info,&pos,info_size)) ||
	  !(tab = mlx_int_str_to_wordtab(line+cpp)) )
	RETURN;
      j = 0;
      while (tab[j] && strcmp(tab[j++],"c"));

      if (!tab[j])
	RETURN;

      rgb_col = mlx_int_get_text_rgb(tab[j], tab[j+1]);
      if (method)
	colors_direct[mlx_int_get_col_name(line,cpp)] = rgb_col;
      else
	{
	  colors[i].name = mlx_int_get_col_name(line,cpp);
	  colors[i].col = rgb_col;
	}
      free(tab);
      tab = 0;
    }

  if (!(img = mlx_new_image(xvar,*width,*height)))
    RETURN;
  data = mlx_get_data_addr(img, &opp, &sl, &endian);
  opp = 4;

  i = *height;
  while (i--)
    {
      if (!(line = f(info,&pos,info_size)))
	RETURN;
      x = 0;
      while (x<*width)
	{
	  col = 0;
	  col_name = mlx_int_get_col_name(line+cpp*x,cpp);
	  if (method)
	    col = colors_direct[col_name];
	  else
	    {
	      j = nc;
	      while (j--)
		if (colors[j].name==col_name)
		  {
		    col = colors[j].col;
		    j = 0;
		  }
	    }
	  if (col==-1)
	    col = 0xFF000000;
	  mlx_int_xpm_set_pixel(data, opp, col, x);
	  x ++;
	}
      data += sl; //img->width*4;
    }
  if (colors)
    free(colors);
  if (colors_direct)
    free(colors_direct);
  return (img);
}


void	mlx_int_file_get_rid_comment(char *ptr, int size)
{
  int	com_begin;
  int	com_end;

  while ((com_begin = mlx_int_str_str_cote(ptr,"/*",size))!=-1)
    {
      com_end = mlx_int_str_str(ptr+com_begin+2,"*/",size-com_begin-2);
      memset(ptr+com_begin,' ',com_end+4);
    }
  while ((com_begin = mlx_int_str_str_cote(ptr,"//",size))!=-1)
    {
      com_end = mlx_int_str_str(ptr+com_begin+2,"\n",size-com_begin-2);
      memset(ptr+com_begin,' ',com_end+3);
    }
}


void	*mlx_xpm_file_to_image(void *xvar,char *file,int *width,int *height)
{
  int	fd;
  int	size;
  char	*ptr;
  void	*img;

  if ((fd = open(file,O_RDONLY))==-1 || (size = lseek(fd,0,SEEK_END))==-1 ||
      (ptr = mmap(0,size,PROT_WRITE|PROT_READ,MAP_PRIVATE,fd,0))==
      (void *)MAP_FAILED)
    {
      if (fd>=0)
	close(fd);
      return ((void *)0);
    }
  mlx_int_file_get_rid_comment(ptr, size);
  img = mlx_int_parse_xpm(xvar,ptr,size,mlx_int_get_line, width, height);
  munmap(ptr,size);
  close(fd);
  return (img);
}

void	*mlx_xpm_to_image(void *xvar,char **xpm_data,int *width,int *height)
{
  return (mlx_int_parse_xpm(xvar,xpm_data,0,mlx_int_static_line, width, height));
}
