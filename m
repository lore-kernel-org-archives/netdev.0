From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPV6: Typo in address comparison
Date: Sun, 26 Oct 2003 23:50:00 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031026235000.7f8df6bb.davem@redhat.com>
References: <20031027.014502.98736584.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / _$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
In-Reply-To: <20031027.014502.98736584.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 27 Oct 2003 01:45:02 +0900 (JST)
YOSHIFUJI Hideaki / _$B5HF#1QL@ <yoshfuji@linux-ipv6.org> wrote:

> Hello.
> 
> Typo found in the local address comparison among sockets.

Oops, Arnaldo and I saw this the other week too, but the
fix for it got lost.

I applied your patch, thank you Yoshfuji.
