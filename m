From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH][IPv6] separation xfrm_lookup from ip6_dst_lookup
Date: Sun, 1 Aug 2004 19:51:35 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040801195135.16734846.davem@redhat.com>
References: <20040730171205.114f22ba.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com, usagi-core@linux-ipv6.org,
        kazunori@miyazawa.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Kazunori Miyazawa <kazunori@miyazawa.org>
In-Reply-To: <20040730171205.114f22ba.kazunori@miyazawa.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 30 Jul 2004 17:12:05 +0900
Kazunori Miyazawa <kazunori@miyazawa.org> wrote:

> I consider copying flowi(fl_rt) uses too much stack at the moment.
> I'll re-send the fixed patch again.

I agree, and let's defer this patch until we
resolve that.

It is simple to fix, I think.
