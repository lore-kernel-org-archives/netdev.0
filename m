From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Prefix List against 2.5.70 (re-done)
Date: Fri, 27 Jun 2003 14:47:52 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030627.144752.78715628.davem@redhat.com>
References: <3EFB2017.5030202@us.ibm.com>
	<20030626.230727.35666164.davem@redhat.com>
	<3EFC668F.9010004@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: krkumar@us.ibm.com
In-Reply-To: <3EFC668F.9010004@us.ibm.com>
List-Id: netdev.vger.kernel.org

   From: Krishna Kumar <krkumar@us.ibm.com>
   Date: Fri, 27 Jun 2003 08:45:19 -0700

   rtnetlink_rcv_msg() calls dumpit() (via netlink_dump_start) only
   for those messages for which the last two bits are binary '10'. So
   I had to use these values. All the other *GET* macros use the same
   semantics.

Ok, please retransmit your two patches (2.4.x and 2.5.x) to me
under seperate cover.  I don't keep a copy around of patches
I've decided not to apply.

