From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Functions Clean-up
Date: Sun, 03 Nov 2002 04:03:38 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021103.040338.98864962.davem@redhat.com>
References: <20021103.115427.104445233.yoshfuji@linux-ipv6.org>
	<1036328414.1048.3.camel@arwen>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   netfilter-devel@lists.netfilter.org, kuznet@ms2.inr.ac.ru,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: kisza@securityaudit.hu
In-Reply-To: <1036328414.1048.3.camel@arwen>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Andras Kis-Szabo <kisza@securityaudit.hu>
   Date: Sun, 03 Nov 2002 14:00:14 +0100

   (And we should not to trust in the kernel.)

If you can't trust the exthdr parser in the kernel, you probably can't
trust the kernel to even give you the packets correctly in the first
place.  So you better just rm -rf netfilter/ while you have the chance
:-)
