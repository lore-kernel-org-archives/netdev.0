From: Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH net] in6: fix conflict with glibc
Date: Sun, 21 Dec 2014 14:56:55 +0100
Message-ID: <1419170215.3663.15.camel@stressinduktion.org>
References: <20141220121549.7c1b8aad@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Florent Fourcot <florent.fourcot-Pj3lBMu8rt9bbU8NOSLlsg@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20141220121549.7c1b8aad@urahara>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sa, 2014-12-20 at 12:15 -0800, Stephen Hemminger wrote:
> Resolve conflicts between glibc definition of IPV6 socket options
> and those defined in Linux headers. Looks like earlier efforts to
> solve this did not cover all the definitions.
> 
> It resolves warnings during iproute2 build. 
> Please consider for stable as well.
> 
> Signed-off-by: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>

Acked-by: Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
