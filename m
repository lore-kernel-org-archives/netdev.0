From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [Bonding-devel] Re: [bonding] compatibilty issues
Date: Fri, 03 Oct 2003 12:57:35 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310031957.h93Jva1U004043@death.ibm.com>
References: <shmulik.hen@intel.com>
Cc: "David S. Miller" <davem@redhat.com>, "Chad N. Tindel" <chad@tindel.net>,
        jgarzik@pobox.com, bonding-devel@lists.sourceforge.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shmulik.hen@intel.com
In-Reply-To: Message from Shmulik Hen <shmulik.hen@intel.com>
   of "Thu, 02 Oct 2003 09:37:51 +0300." <200310020937.51781.shmulik.hen@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


>Where should such a list go ?

	Oh, I was thinking either in a comment block (by the ABI
version definitions, for example), tacked on to the end of
bonding.txt, or maybe in a README.ABI in the bonding/ directory.  I'm
not too concerned about where it is.  I just don't want to find
ourselves a year or two down the road trying to figure out just what
ABI version N is supposed to do when it suddenly quits working....

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
