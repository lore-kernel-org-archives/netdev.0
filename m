From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH SET][bonding] cleanup
Date: Thu, 25 Sep 2003 09:22:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309251622.h8PGMaD1013425@death.ibm.com>
References: <shmulik.hen@intel.com>
Cc: bonding-devel@lists.sourceforge.net,
        bonding-announce@lists.sourceforge.net, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
        "Jeff Garzik" <jgarzik@pobox.com>,
        "Noam,
    Amir" <amir.noam@intel.com>,
        "Mendelson,
    Tsippy" <tsippy.mendelson@intel.com>,
        "Noam,
    Marom" <noam.marom@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: shmulik.hen@intel.com
In-Reply-To: Message from Shmulik Hen <shmulik.hen@intel.com>
   of "Thu, 25 Sep 2003 15:49:59 +0300." <200309251549.59177.shmulik.hen@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


>patch 7 - eliminate the multicast_mode module param. settings are now 
>          done only according to mode.

	This goes a bit beyond straight cleanup; could you explain the
rationale for this change?  Also, unless I'm missing something, the
patch does not appear to update bonding.txt to reflect the fact that
the module parameter is no more.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
