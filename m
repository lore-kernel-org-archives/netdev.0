From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [Bonding-devel] Re: [PATCH 2/10] [bonding 2.6] fix monitoring functions
Date: Thu, 30 Oct 2003 09:12:18 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310301712.h9UHCJNI014973@death.ibm.com>
References: <amir.noam@intel.com>
Cc: "Jeff Garzik" <jgarzik@pobox.com>, davem@redhat.com,
        bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Amir Noam <amir.noam@intel.com>
In-Reply-To: Message from Amir Noam <amir.noam@intel.com>
   of "Thu, 30 Oct 2003 10:56:07 +0200." <200310301056.07221.amir.noam@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


>However, the following patch that restores backward compatibility with
>old ifenslave is still needed for 2.6. I see that it's already been
>applied by David Miller to 2.4.

	I thought we were dropping the ancient (SIOCDEVPRIVATE)
backwards compatibility in 2.6.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
