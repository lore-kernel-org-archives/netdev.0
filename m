From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: recommendations for NIC HW(/SW) design?
Date: Sun, 26 Sep 2004 17:29:55 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040926152955.GD17043@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I'm working on a NIC driver for the Intel IXP network processor (I've
got an almost releasable version at this point), but now I'm wondering
about the following.  Because the chip is programmable and I'm writing
the firmware myself, I am more-or-less free to determine which features
the hardware will implement, and more-or-less free to define the
hardware-software interface.

Does any of you have any general recommendations for this?  Is there
anything I should certainly implement, or any design mistakes that I
should certainly avoid?

(Since the Intel IXP processor is just an ARM processor with a network
interface grafted onto the chip, a bunch of things that apply to PCI
NIC design might not apply here.)


thanks,
Lennert
