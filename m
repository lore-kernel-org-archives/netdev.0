From: "David S. Miller" <davem@redhat.com>
Subject: Re: [patch]: CONFIG_IPV6_SUBTREES fix for MIPv6
Date: Thu, 12 Jun 2003 01:49:39 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030612.014939.56032563.davem@redhat.com>
References: <3EE6ECD3.6050103@tml.hut.fi>
	<20030611.202003.74721468.davem@redhat.com>
	<3EE83D81.5030605@tml.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nakam@linux-ipv6.org, lpetande@morphine.tml.hut.fi,
   yoshfuji@linux-ipv6.org, vnuorval@tcs.hut.fi, kuznet@ms2.inr.ac.ru,
   netdev@oss.sgi.com, ajtuomin@morphine.tml.hut.fi, jagana@us.ibm.com,
   kumarkr@us.ibm.com, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: lpetande@tml.hut.fi
In-Reply-To: <3EE83D81.5030605@tml.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Henrik Petander <lpetande@tml.hut.fi>
   Date: Thu, 12 Jun 2003 11:44:49 +0300
   
   MIPv6 daemon would do this after  getting a notification of the
   deletion of the old mipv6 related cached routes.

Ok.
