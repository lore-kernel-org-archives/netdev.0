From: Meelis Roos <mroos@linux.ee>
Subject: Re: 2.6.10-rc2: still no ipv6 link-local addresses
Date: Mon, 15 Nov 2004 14:55:46 +0200
Message-ID: <E1CTgOY-00019E-Nq@rhn.tartu-labor>
References: <Pine.SOC.4.61.0411151159230.3321@math.ut.ee>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <Pine.SOC.4.61.0411151159230.3321@math.ut.ee>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

MR> I tried 2.6.10-rc2 and it still does not give lipv6 link-local address 
MR> to Ethernet interfaces (I tried NICs with e100 and 8139too drivers).

Hmm, eth1 with 8139too has gotten a link-local address meanwhile - maybe
after up'ing the interface. e100 is my primary NIC and is up and working
but still does not have link-local address.

-- 
Meelis Roos
