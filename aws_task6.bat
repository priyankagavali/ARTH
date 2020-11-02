
aws ec2 create-volume --availability-zone ap-south-1a --size 5 --query VolumeId --output text >volume.txt

aws ec2 create-key-pair --key-name priyanka --query KeyMaterial --output text  > priyanka.pem

SET keysave="priyanka.pem"

aws ec2 run-instances --image-id ami-0e306788ff2473ccb --instance-type t2.micro --count 1   --security-group-ids sg-c74416a0 --key-name priyanka --query Instances[].InstanceId --output text > id.txt

SET /pid Iid=<id.txt

timeout 90

aws ec2 attach-volume --device /dev/xvdf --instance-id %Iid% --volume-id file://volume.txt

aws ec2 describe-instances --query Reservations[-1].Instances[].[PublicDnsName] --output text > instanceid1.text

set /p Iid1=<instanceid1.txt

ssh -i %savekey% ec2-user@%Iid1% sudo yum install httpd -y

ssh -i %savekey% ec2-user@%Iid1% sudo fdisk /dev/xvdf

ssh -i %savekey% ec2-user@%Iid1% sudo mkfs.ext4 /dev/xvdf1

ssh -i %savekey% ec2-user@%Iid1% sudo mount /dev/xvdf1 /var/www/html

aws s3api create-bucket --bucket priyanka022 --region ap-south-1 --create-bucket-configuration LocationConstraint=ap-south-1

SET imagepath=C:\Users\priyanka\images.jpg

SET image =images.jpg

aws s3 cp %imagepath% s3.//priyanka022/

SET s3="https://priyanka022.s3.ap-south-1.amazonaws.com/%image%"

SET domain_name=priyanka022.s3.ap-south-1.amazonaws.com

aws cloudfront create-distribution --origin-domain-name %domain_name% --query Distribution.DomainName --output text > cloudfront.txt

timeout 90

SET /p cloudfront=<cloudfront.txt

SET url="<body><center><h1>"Task Successfully Completed....!!</h1><img src=https://%cloudfront%/%image% alt="dont loaded" width = "500" height = "500"></center></body>"

echo %url% > url.html

scp -i %savekey% -r url.html ec2-user@%Iid1%:~

ssh -i %key% ec2-user@%Iid1% sudo sed 's/\"//g' url.html > sample.html

ssh -i %savekey% ec2-user@%Iid1% sudo cp sample.html /var/www/html/

ssh -i %savekey% ec2-user@%Iid1% sudo systemctl start httpd







