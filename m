From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH]: invaild TCP/UDP matching when ipv6 extension header
 exists
Date: Fri, 20 Feb 2004 09:31:58 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040220093158.3c12ea9a.davem@redhat.com>
References: <200401310649.PAA00050@toshiba.co.jp>
	<200402200612.PAA12001@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com,
        usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
In-Reply-To: <200402200612.PAA12001@toshiba.co.jp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 20 Feb 2004 15:12:17 +0900 (JST)
Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp> wrote:

> I sent the patch which fixes this bug to netfilter-devel, but it include
> other bug... sorry, I rewrite patch for ip6_tables.c .
> 
> Please don't forget apply the patch which fixes the bug in ipv6_skip_exthdr()
> before you tests this patch. I sent it last few minutes to netdev and
> netfilter-devel.

I have applied this patch too, thanks a lot.
