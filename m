From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: RFC: network device management doc draft
Date: Mon, 23 Feb 2004 17:10:18 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040224011018.GA18818@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, "David S. Miller" <davem@redhat.com>,
        David Hinds <dahinds@users.sourceforge.net>,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

	Hi,

	I'm currently working on a documentation on how to manage
network interfaces. This is the result of my migration away from the
old Pcmcia scripts. Nothing earth shattering, but the combination of
various existing stuff, how to make them work together, and how to
handle any weird network card configuration.
	I value feedback and comments. Before exposing this to average
users, I would like to make sure that the "gurus" nit-pick my
stuff. I'm especially interested in any scenario I might have
overlooked where those techniques would fail.

	The document is at :
http://www.hpl.hp.com/personal/Jean_Tourrilhes/Linux/WIRELESS-HOTPLUG.txt

	Thanks in advance...

	Jean
