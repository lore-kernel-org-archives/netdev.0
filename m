From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH, TAKE 2] [IPV6] XFRM: extract xfrm_lookup() from
 ip6_dst_lookup() (is Re: [PATCH][IPv6] separation xfrm_lookup from
 ip6_dst_lookup)
Date: Fri, 27 Aug 2004 17:02:32 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040827170232.590eebb6.davem@davemloft.net>
References: <20040730171205.114f22ba.kazunori@miyazawa.org>
	<20040801195135.16734846.davem@redhat.com>
	<20040828.014935.131415609.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com, usagi-core@linux-ipv6.org, kazunori@miyazawa.org,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040828.014935.131415609.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 28 Aug 2004 01:49:35 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> > It is simple to fix, I think.
> 
> Here's the updated patch.
> 
> From: Kazunori Miyazawa <kazunori@miyazawa.org>
> 
> (Because Miyazawa-san is very busy now, 
> I'm sending this patch as the proxy of him.)
> 
> Please pull from <bk://bk.skbuff.net:20609/linux-2.6-xfrm/>

Looks great, pulled.
