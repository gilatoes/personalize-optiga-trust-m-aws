echo "Clearing Files"
sudo rm *.csr
sudo rm *.der
sudo rm *.pem
sudo rm cli_output.jsn
set -e
echo "Generate CSR using Trust X"
sudo ../bin/rpi3_linux_arm/optiga_generate_csr -f /dev/i2c-1 -o optiga_AWS.csr -i config.jsn
echo "Create AWS CA signed device cert "
aws iot create-certificate-from-csr  --certificate-signing-request file://optiga_AWS.csr --certificate-pem-outfile optiga_AWS.pem --set-as-active > cli_output.jsn
echo "Creating Thing in AWS Core"
aws iot create-thing --thing-name `jq -r '.ThingName' config.jsn`
echo "Attached Cert and Policy"
aws iot attach-thing-principal --thing-name `jq -r '.ThingName' config.jsn` --principal `jq -r '.certificateArn' cli_output.jsn`

aws iot attach-policy --policy-name XMC_Policy --target `jq -r '.certificateArn' cli_output.jsn`

echo "Write Cert binary to Trust X"
openssl x509 --in optiga_AWS.pem --inform PEM --out optiga_AWS.der --outform DER
sudo ../bin/rpi3_linux_arm/optiga_upload_crt -f /dev/i2c-1 -c optiga_AWS.der
