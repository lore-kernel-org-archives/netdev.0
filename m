From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPV6: kill obsolete functions
Date: Thu, 1 Jan 2004 12:24:30 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040101122430.4fcf6bfd.davem@redhat.com>
References: <20040101.154305.69668715.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / _$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
In-Reply-To: <20040101.154305.69668715.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 01 Jan 2004 15:43:05 +0900 (JST)
YOSHIFUJI Hideaki / _$B5HF#1QL@ <yoshfuji@linux-ipv6.org> wrote:

> We've migrated to ip6_append_data(). Old functions such as
> ip6_frag_xmit() and ip6_build_xmit() are no longer used.
> 
> D: kill obsolete functions.

Applied, arigato Yoshfuji-san.
