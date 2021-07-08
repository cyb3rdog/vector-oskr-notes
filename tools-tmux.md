
## Environment - TMUX

I like to simplify my life with tools I am used to. TMUX is one of them. Here are two examples of pre-configured sessions I am using:

### Use on Vector

In case, you're using the [**Cyb3rTools**](https://github.com/cyb3rdog/vector-oskr-notes/blob/main/packages/README.md) and have installed tmux to your Vector,
you can just use these pre-configgured tmux sessions directly by calling **`tmux-vic`** or **`tmux-dev`**.

#### 1. **`tmux-vic`** on Vector
- Install the **`tmux`** to your Vector with the [**Cyb3rTools**](https://github.com/cyb3rdog/vector-oskr-notes/blob/main/packages/README.md), if not already installed
- Use this tmux session by calling **`tmux-vic`**; detach using **`tmux detach`**, or *[Ctrl+B], [d]*

![image](https://user-images.githubusercontent.com/12493945/122396776-a2d7aa00-cf78-11eb-8c55-3b573527f5bb.png)

#### 2. **`tmux-dev`** on Vector
- Install the **`tmux`**, **`mc`** and **`htop`** to your Vector with the [**Cyb3rTools**](https://github.com/cyb3rdog/vector-oskr-notes/blob/main/packages/README.md), if not already installed
- Use this tmux session by calling **`tmux-dev`**; detach using **`tmux detach`**, or *[Ctrl+B], [d]*

![image](https://user-images.githubusercontent.com/12493945/122397067-e6321880-cf78-11eb-96ae-87996ec49ed8.png)


### Remote Use:

In case, you preffer to do your work remotelly, the following scripts offer the very same as above, except for that the `tmux-vic` is connecting all three of it's panels to your Vector over SSH:

#### 1. **[tmux-vic](https://github.com/cyb3rdog/vector-oskr-notes/blob/main/scripts/tmux-vic) on Remote computer**

- Download the [tmux-vic](https://github.com/cyb3rdog/vector-oskr-notes/blob/main/scripts/tmux-vic) file, edit and change the ```SSH_VECTOR``` variable in it 
- Copy this file to your favorite location, i.e. ```sudo cp ./tmux-vic /usr/local/bin```
- Make it executable ```chmod +X /usr/local/bin/tmux-vic```
- Use the tmux *vector session* by calling **`tmux-vic`**; detach using **`tmux detach`**, or *[Ctrl+B], [d]*

#### 2. **[tmux-dev](https://github.com/cyb3rdog/vector-oskr-notes/blob/main/scripts/tmux-dev) on Remote computer**

- Download the [tmux-dev](https://github.com/cyb3rdog/vector-oskr-notes/blob/main/scripts/tmux-dev) file. 
- Copy this file to your favorite location, i.e. ```sudo cp ./tmux-dev /usr/local/bin```
- Make it executable ```chmod +X /usr/local/bin/tmux-dev```
- Use the tmux *dev session* by calling **`tmux-dev`**; detach using **`tmux detach`**, or *[Ctrl+B], [d]*


