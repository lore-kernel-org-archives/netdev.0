From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] IPv6: Default Route Support on Router
Date: Sun, 29 Sep 2002 04:08:22 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020929040822.A8491@wotan.suse.de>
References: <20020928.151959.131438421.yoshfuji@linux-ipv6.org> <200209282047.AAA03890@sex.inr.ac.ru> <20020928.172306.102654240.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.ORG, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20020928.172306.102654240.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Sep 28, 2002 at 05:23:06PM -0700, David S. Miller wrote:
>    From: kuznet@ms2.inr.ac.ru
>    Date: Sun, 29 Sep 2002 00:47:05 +0400 (MSD)
> 
>    One question, what is this chunk for?
> 
> This reminds me, nothing is aparently going to make use
> of net/ipv6/ip6_fw.c, it sits unused and untouched for
> years, can we just detroy it? :-)

It never worked correctly and was unfinished. I would destroy it.

-Andi
