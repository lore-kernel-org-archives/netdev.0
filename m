From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Updated Wireless Extension patches
Date: Tue, 29 Jun 2004 09:23:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040629162339.GA4356@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Linux kernel mailing list <linux-kernel@vger.kernel.org>,
        netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

	Hi all,

	I've been working a bit more on my current set of Wireless
Extension patches (WPA, Wireless-RtNetlink, ...). I've just updated
them on my personal web page :
	http://www.hpl.hp.com/personal/Jean_Tourrilhes/Linux/Tools.html#wext

	The main change is that I'm now happy of the format of
Wireless over RtNetlink, so it should be close to definitive. I've
also split all the minor changes as a separate patch (WE-17), so it
doesn't have to wait for WPA and Wireless-RtNetlink that still need a
bit of work, and I plan to push this patch soon.
	You will also find patches for various drivers to take
advantage of the new features. I would like to thank the various
driver authors that sent me patches, suggestions and comments, and
thank them for their patience.

	Have fun...

	Jean
