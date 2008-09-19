From: "Julius Volz" <juliusv@google.com>
Subject: [PATCH] IPVS: Move IPVS to net/netfilter/ipvs
Date: Fri, 19 Sep 2008 12:45:47 +0200
Message-ID: <f4845fc0809190345k1d9f8ba6i53d891548ddb0565@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org
To: "Simon Horman" <horms@verge.net.au>
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Horms,

I worked around the unrelated UML build problems for now and did the
IPVS move from net/ipv4/ipvs to net/netfilter/ipvs, as discussed.
Since the patch is huge (732K), I uploaded it rather than trying to
include it in the mail:

http://www.mindbasket.com/ipvs/0001-IPVS-Move-IPVS-to-net-netfilter-ipvs.patch

The menuconfig option for IPVS is now also in the Netfilter submenu.
Everything builds and runs ok here...

Julius

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
