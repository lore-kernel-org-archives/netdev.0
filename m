From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Functions Clean-up
Date: Sun, 23 Feb 2003 23:18:47 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030223.231847.58640988.davem@redhat.com>
References: <20030223.225426.28829614.davem@redhat.com>
	<20030224.161815.511623971.yoshfuji@linux-ipv6.org>
	<20030224.162911.826686204.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   netfilter-devel@lists.netfilter.org, kuznet@ms2.inr.ac.ru,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20030224.162911.826686204.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Mon, 24 Feb 2003 16:29:11 +0900 (JST)

   In article <20030224.161815.511623971.yoshfuji@linux-ipv6.org> (at Mon, 24 Feb 2003 16:18:15 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:
   
   > sorry, I had compiled with wrong options... :-p
   > just a moment, please...
   
   Please apply this patch on top of the previous patch.
   Sorry for the mess.

As I said, I fixed it already by using pfx->s6_addr.

No problems and no need to apologize :)
