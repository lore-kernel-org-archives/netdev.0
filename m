From: Damian <res0d26i@verizon.net>
Subject: sis900 and fedora troubles
Date: Fri, 24 Jun 2005 19:49:25 -0700
Message-ID: <1119667765.8496.6.camel@localhost.localdomain>
Reply-To: res0d26i@verizon.net
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

1) I'm having trouble with the sis900 chipset on an Acer Aspire 3000
Laptop using Fedora Core 4, which I believe uses 2.6.11. The NIC is
detected perfeclty by fedora but it fails to initialize. When I set it
for dhcp the dhcp request simply times out. I have tried this laptop
with ubuntu linux and it works perfectly out of the box so I cannot
explain why it wouldn't work in fedora.

2) 
Error: Determining IP information for eth0... failed. (redhat gui
network config)

Error: eth0: Transmit timeout, status 00000005 000002
(/var/log/messages)

3) dmesg: card is detected.

I am so very sorry I can't give you more output, but the laptop is
virtually connectionless. All I can tell you is that Ubuntu ran the card
fine but Fedora for some reason doesn't. Any info is highly appreciated.

Damian
