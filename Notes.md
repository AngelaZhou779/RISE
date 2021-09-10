##Sep 10
Had trouble setting up google sdk on my local terminal (new mac). Fixed it with the following steps\

The default shell is probably zsh; checked with "echo $SHELL". Got /bin/zsh, changed using "chsh -s /bin/bash"\
Then followed steps at 'https://cloud.google.com/sdk/docs/downloads-interactive?authuser=1#linux-mac'
Terminal did not recognize command 'gcloud'. Fixed this by following the directions here: https://stackoverflow.com/questions/31037279/gcloud-command-not-found-while-installing-google-cloud-sdk
Essentially, I used these two commands:
source '/Users/cottonellezhou/google-cloud-sdk/path.bash.inc'
source '/Users/cottonellezhou//google-cloud-sdk/completion.bash.inc'

For time zone, select option 2
After those steps, I can now access google sdk on my local terminal.
