From: Arjen Verweij <A.Verweij2@ewi.tudelft.nl>
Subject: [Forcedeth] Wake-on-LAN support?
Date: Mon, 12 Jan 2004 12:01:02 +0100 (MET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GHP.4.44.0401121152250.1675-100000@elektron.its.tudelft.nl>
Reply-To: a.verweij@student.tudelft.nl
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: c-d.hailfinger.kernel.2003@gmx.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

L.S.,

First, many thanks for your efforts. The driver works beautifully here,
with 2.4.23 and 2.6.0-test11 alike.

I was wondering if it is possible to add Wake-on-LAN support to the
driver. NVidia claims their binary driver supports WOL, but it doesn't
work one bit. It is possible to look into this?

I have filed a bugtracker with the ACPI people, but they are somewhat
understandably preoccupied with fixing laptop woes.

URL:
http://bugzilla.kernel.org/show_bug.cgi?id=1636

I am able to enable WOL at shutdown with pci-config from scyld.com, but
this is obviously an ugly fix.

Regards,

Arjen
