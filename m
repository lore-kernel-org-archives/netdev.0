From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPV6: kill in6_u.u6_addrX
Date: Wed, 11 Feb 2004 21:14:22 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040211211422.42241389.davem@redhat.com>
References: <20040212.140022.128605177.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040212.140022.128605177.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 12 Feb 2004 14:00:22 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> There're still two in6_u.u6_addrX in the tree.
> (I've grep'ed the tree.)
> 
> D: kill in6_u.u6_addrX and use s6_addrX instead.

Applied, thanks yoshfuji.
