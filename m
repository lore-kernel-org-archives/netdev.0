From: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Subject: Why /sys/class/net/*/features is read-only?
Date: Mon, 23 May 2005 10:46:50 +0300 (EEST)
Message-ID: <Pine.LNX.4.62.0505201346420.29305@webhosting.rdsbv.ro>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

Why features file is read-only. If an admin want to force some attributes, 
we can let them, right?

This way, an admin can force SG and HW_CSUM on a bridge, for example. ;)

I can make a patch, if you want.

Thank you!
---
Catalin(ux aka Dino) BOIE
catab at deuroconsult.ro
http://kernel.umbrella.ro/
