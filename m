From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] XFRM: ICMP{,v6} type/code support (Take 2) (was Re:
 [PATCH][IPSEC] IPsec policy can be matched by ICMP type and code)
Date: Wed, 18 Aug 2004 15:24:42 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040818152442.42d27cbb.davem@redhat.com>
References: <20040809175404.301bd60a@localhost>
	<20040809170705.6ab75c5f.davem@redhat.com>
	<20040818.230936.59708655.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: nakam@linux-ipv6.org, netdev@oss.sgi.com, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040818.230936.59708655.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 18 Aug 2004 23:09:36 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> > Truly %100 RAW sockets should have their packets untouched by
> > the kernel.  User wants exactly that packet to be sent onto
> > the wire.
> 
> Here's the updated version of the patch.
> Changesets are available at:
> 	<bk://bk.skbuff.net:20609/linux-2.6-xfrm-icmp/>.

Pulled, thanks Yoshifuji.
