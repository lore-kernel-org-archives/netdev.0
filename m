From: Michiel Borkent <borkdude@cs.utwente.nl>
Subject: 3c59x support
Date: Tue, 29 Apr 2003 02:02:02 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200304290202.02811.borkdude@cs.utwente.nl>
Reply-To: borkdude@cs.utwente.nl
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, andrewm@uow.edu.au, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,
I am trying to make a 2.4.20 kernel with 3c59x support.
My card is a:

3Com 3c900 Cyclone 10Mbps TPO 

card and it only works with the 3c59x-scyld module, I found with Debian Woody 
with a linux v2.2 kernel.

It does NOT work with the normal 3c59x module and as I am trying to make a 
2.4.20 kernel, it still doesn't work. I chose support for "Vortex/Boomerang" 
and normally my card would be supported I think.

Can someone help me with this?

Greetings,
Michiel Borkent
