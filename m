From: Shmulik Hen <shmulik.hen@intel.com>
Subject: Re: [bonding] compatibilty issues
Date: Tue, 30 Sep 2003 14:42:31 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309301442.31991.shmulik.hen@intel.com>
References: <E791C176A6139242A988ABA8B3D9B38A02A464F1@hasmsx403.iil.intel.com>
Reply-To: shmulik.hen@intel.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, "Jeff Garzik" <jgarzik@pobox.com>,
        <chad@tindel.net>, "Jay Vosburgh" <fubar@us.ibm.com>
In-Reply-To: <E791C176A6139242A988ABA8B3D9B38A02A464F1@hasmsx403.iil.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Guys,

I'm going to need a ruling here :)
Re-creating those 19 trees each time is killing me and I would like to 
reduce the number of iterations to a minimum.
I'm currently working on putting back all compatibility stuff for 2.4. 
I would like to also get any input/reservations about other issues 
(besides compatibility and the multicast param) so I may get a chance 
to get them all in at once.

Once we get that settled, I can start working on a 2.6 version that 
also handles any compatibility issues (preferrably as the last patch 
of the series). I'm working in the assumption that 2.4-2.6 similarity 
is no longer an option for bonding.

-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |
