|   Program name   | cub3D                                                        |
| :--------------------: | ----------------------------------------------------- |
|  Turn in files   | All your files                                               |
|     Makefile     | all, clean, fclean, re, bonus                                |
| External functs. | •open, close, read, write, malloc, free, perror, strerror, exit <br />• All functions of the math library (-lm man man 3 math) <br />• All functions of the MinilibX |
| Libft authorized | Yes                                                          |
|   Description   | You must create a “realistic” 3D graphical representation of the inside of a maze from a first person perspective. You have to create this representation using the Ray-Casting principles mentioned earlier. |



**The constraints are as follows:** 

**제약조건은 다음과 같다:**

• You must use the miniLibX. Either the version that is available on the operating system, or from its sources. If you choose to work with the sources, you will need to apply the same rules for your libft as those written above in Common Instructions part. 

•miniLibXf를 사용해야 된다. OS 별로 가능한 버전을 사용하거나 소스에서 제공되는 것으로 사용해도 된다. 소스에서 제공되는 것을 쓴다면 ??



• The management of your window must remain smooth: changing to another window, minimizing, etc. 

• 창의 관리는 부드러워야(자연스러워야?) 한다. (예를 들어 다른 창으로 옮기거나, 최소화하거나 등등)



• Display different wall textures (the choice is yours) that vary depending on which side the wall is facing (North, South, East, West).

• 동서남북 별로 벽은 다른 텍스쳐를 보여야한다. 자신이 고른 이미지를 쓰면 된다.



• Your program must be able to display an item (sprite) instead of a wall. 

• 너의 프로그램은 벽 대신 아이템(스프라이트)을 보여줄수 있어야 한다.



• Your program must be able to set the floor and ceilling colors to two different ones. 

• 너의 프로그램은 바닥과 천장을 두가지 다른 색으로 칠해질 수 있어야한다.



• In case the Deepthought has eyes one day to evaluate your project, your program must save the first rendered image in bmp format when its second argument is "––save". 

• Deepthought가 너의 프로젝트를 평가 할수 있을때를 대비하여, 두번째 인자로 "--save"가 입력됐을 때 너의 프로그램은 첫번째 렌더링 이미지(bmp format)을 저장해야한다.



• If no second argument is supllied, the program displays the image in a window and respects the following rules:

• 두번째 인자가 제공되지 않는다면, 프로그램은 다음과 같은 룰에 따라 창안에 이미지를 띄워야 한다.

​	◦ The left and right arrow keys of the keyboard must allow you to look left and right in the maze. 

​	◦ 왼쪽, 오른쪽 화살표키는 미로의 왼쪽과 오른쪽을 볼수 있게 해야한다.

​	◦ The W, A, S and D keys must allow you to move the point of view through the maze. 

​	◦ W,A,S,D키는 미로안에서의 시점을 움질일 수 있게 해야 한다.

​	◦ Pressing ESC must close the window and quit the program cleanly. 

​	◦ ESC로 창이 닫히고 프로그램이 깔끔히 종료되어야 한다.

​	◦ Clicking on the red cross on the window’s frame must close the window and quit the program cleanly. 

​	◦ 창의  빨간색 x버튼으로 창이 닫히고 프로그램이 깔끔히 종료되어야 한다.

​	◦ If the declared screen size in the map is greater than the display resolution, the window size will be set depending to the current display resolution. 

​	맵에 지정된 스크린 사이즈가 화면 해상도보다 큰 경우, 창의 사이즈는 현재 화면 해상도에 맞춰서 세팅되어야 한다.

​	◦ The use of images of the minilibX is strongly recommended.

​	◦ minilibX의 이미지 사용을 적극 권장한다.



• Your program must take as a first argument a scene description file with the .cub extension. 

• 너의 프로그램은 첫번째 인자로 .cub 확장자로 된 장면 상세파일을 받아야 한다.

​	◦ The map must be composed of only 4 possible characters: 0 for an empty space, 1 for a wall, 2 for an item and N,S,E or W for the player’s start position and spawning orientation. This is a simple valid map:

​	◦ 맵은 4가지 문자로 이루어져 있어야 한다. 0: 빈칸, 1: 벽, 2: 아이템, N,S,E,W: 플레이어 시작지점(태어났을때 바라볼 방향)
​		다음은 위 조건사항을 충족시키는 간단한 맵이다.

```
111111
100101
102001
1100N1
111111
```

​	◦ The map must be closed/surrounded by walls, if not the program must return an error. 

​	◦ 지도는 벽으로 둘러쌓여있어야 한다. 그렇지 않은경우 프로그램은 에러를 return해야 한다.

​	◦ Except for the map content, each type of element can be separated by one or more empty line(s). 

​		맵을 제외하고는 각 요소들은 한 줄 이상으로 구분될 수 있다.

​	◦ Except for the map content which always has to be the last, each type of element can be set in any order in the file. 
​	◦ 하단에 위치해야 하는 맵을 제외하고는 각 요소들은 순서가 제각각일 수 있다.

​	◦ Except for the map, each type of information from an element can be separated by one or more space(s). 
​	◦ 맵을 제외하고는 각 요소안의 정보들은 하나 이상의 공백으로 구분될 수 있다.

​	◦ The map must be parsed as it looks like in the file. Spaces are a valid part of the map, and is up to you to handle. You must be able to parse any kind of map, as long as it respects the maps rules.

​	◦ 맵은 파일에 있는 그대로 파싱 되어야 한다. 공백이 맵에 있을 수 있으며, 어떻게 처리할 지는 당신에게 달려 있다. map 규칙을 따르는 한 당신은 어떤 종류의 맵도 파싱해야 한다.

​	◦ Each element (except the map) firsts information is the type identifier (composed by one or two character(s)), followed by all specific informations for each object in a strict order such as : 
​	◦ 맵을 제외한 각 요소의 첫번째 정보는 (한개 혹은 두개의 글자로 이루어진) type identifier이다

​		∗ Resolution: 
​			`R 1920 1080`

​			 · identifier: R 

​			· x render size 

​			· y render size 

​		∗ North texture: 

​			`NO ./path_to_the_north_texture` 

​			· identifier: NO 

​			· path to the north texure 

​		∗ South texture: 

​			`SO ./path_to_the_south_texture` 

​			· identifier: SO 

​			· path to the south texure 

​		∗ West texture: 

​			`WE ./path_to_the_west_texture` 

​			· identifier: WE 

​			· path to the west texure 

​		∗ East texture: 

​			`EA ./path_to_the_east_texture` 

​			· identifier: EA 

​			· path to the east texure 

​		∗ Sprite texture: 

​			`S ./path_to_the_sprite_texture` 

​			· identifier: S 

​			· path to the sprite texure 

​		∗ Floor color: 

​			`F 220,100,0` 

​			· identifier: F 

​			· R,G,B colors in range [0,255]: 0, 255, 255

​		∗ Ceilling color: 

​			`C 225,30,0 `

​			· identifier: C 

​			· R,G,B colors in range [0,255]: 0, 255, 255 

◦ Example of the mandatory part with a minimalist **.cub** scene:

```
R 1920 1080
NO ./path_to_the_north_texture
SO ./path_to_the_south_texture
WE ./path_to_the_west_texture
EA ./path_to_the_east_texture
S ./path_to_the_sprite_texture
F 220,100,0
C 225,30,0
        1111111111111111111111111
        1000000000110000000000001
        1011000001110000002000001
        1001000000000000000000001
111111111011000001110000000000001
100000000011000001110111111111111
11110111111111011100000010001
11110111111111011101010010001
11000000110101011100000010001
10002000000000001100000010001
10000000000000001101010010001
11000001110101011111011110N0111
11110111 1110101 101111010001
11111111 1111111 111111111111
```

◦ If any misconfiguration of any kind is encountered in the file, the program must exit properly and return "Error\n" followed by an explicit error message of your choice.

