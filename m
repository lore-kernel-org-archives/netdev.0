From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH][IPv6] separation xfrm_lookup from ip6_dst_lookup
Date: Tue, 10 Aug 2004 10:38:30 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040810.103830.13065766.yoshfuji@linux-ipv6.org>
References: <20040801195135.16734846.davem@redhat.com>
	<20040803.020015.44364045.yoshfuji@linux-ipv6.org>
	<20040809163520.2873a3c8.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kazunori@miyazawa.org, herbert@gondor.apana.org.au, netdev@oss.sgi.com,
        usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20040809163520.2873a3c8.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040809163520.2873a3c8.davem@redhat.com> (at Mon, 9 Aug 2004 16:35:20 -0700), "David S. Miller" <davem@redhat.com> says:

> Instead, I would try to arrange order of events such that
> single stack copy can be modified.  Something like:

Thanks for clarification.

Miyazawa-san will take care of this when he has returned from another 
conference.

--yoshfuji
