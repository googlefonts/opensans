# Open Sans
variable font

![Open Sans sample](/docs/sample.png)

Originally designed by Steve Matteson of Ascender  
Hebrew by Yanek Iontef  
Weight expansion by Micah Stupak  
Help and advice from Meir Sadan and Marc Foley


## Building fonts

```
# Create a new virtual env and install dependencies
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt


# Change to source dir and generate fonts
cd source
sh build.sh
```
