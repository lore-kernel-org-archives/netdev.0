From: "David S. Miller" <davem@redhat.com>
Subject: Re: [Bonding-devel] [patch] (2/8) Add 802.3ad support to bonding
 (released to bonding on sourceforge)
Date: Thu, 20 Mar 2003 16:08:45 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030320.160845.121240938.davem@redhat.com>
References: <OF102C4F31.A103F2FF-ON88256CEF.007C2E59@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hshmulik@intel.com, bonding-devel@lists.sourceforge.net,
   bonding-announce@lists.sourceforge.net, linux-net@vger.kernel.org,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: fubar@us.ibm.com
In-Reply-To: <OF102C4F31.A103F2FF-ON88256CEF.007C2E59@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Jay Vosburgh <fubar@us.ibm.com>
   Date: Thu, 20 Mar 2003 14:53:14 -0800
   
         I have incorporated Shmulik Hen's bug fix patches to bonding (patch
   numbers 2 and 3) into the current code and released the new patch to
   sourceforge.net/projects/bonding.  The current bonding update is
   bonding-2.4.20-20030320.  The only changes I made were minor spelling /
   formatting fixes.

So when do these changes end up being sent to myself or
Jeff for mainline inclusion?

I have no objection to the sourceforge project for bonding, but
I do object to there being such latency between what the sourceforge
tree has (especially bug fixes) and what gets submitted into the
mainline.

Personally, I'd prefer that all development occur in the mainline
tree.  That gives you testing coverage that is impossible otherwise.
