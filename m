From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6 IPsec AH typo
Date: Fri, 16 Apr 2004 14:53:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040416145317.67832409.davem@redhat.com>
References: <20040415210223.24aabc4a@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Masahide NAKAMURA <nakam@linux-ipv6.org>
In-Reply-To: <20040415210223.24aabc4a@localhost>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 15 Apr 2004 21:02:23 +0900
Masahide NAKAMURA <nakam@linux-ipv6.org> wrote:

> this patch fixes a typo. Please apply it.
 ...
> -	err = xfrm_check_output(x, skb, AF_INET);
> +	err = xfrm_check_output(x, skb, AF_INET6);

It is fine, patch applied.

Thanks.
