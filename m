From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2/2] IPV6: use ipv6_addr_is_multicast()
Date: Wed, 28 Jan 2004 16:06:59 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040128160659.305291c4.davem@redhat.com>
References: <20040128.163047.87255505.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040128.163047.87255505.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 28 Jan 2004 16:30:47 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> Use simple ipv6_addr_is_multicast()
> where ipv6_addr_type() is called to check for multicast only.
> 
> Thanks.

Also applied, arigato.
