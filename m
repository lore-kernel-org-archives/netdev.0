From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 2/2] net-next: ethernet: mediatek: change the
 compatible string
Date: Wed, 25 Jan 2017 14:36:20 -0500 (EST)
Message-ID: <20170125.143620.2147272337043372320.davem@davemloft.net>
References: <1485332455-34743-1-git-send-email-john@phrozen.org>
        <1485332455-34743-2-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1485332455-34743-2-git-send-email-john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>
Date: Wed, 25 Jan 2017 09:20:55 +0100

> When the binding was defined, I was not aware that mt2701 was an earlier
> version of the SoC. For sake of consistency, the ethernet driver should
> use mt2701 inside the compat string as this is the earliest SoC with the
> ethernet core.
> 
> The ethernet driver is currently of no real use until we finish and
> upstream the DSA driver. There are no users of this binding yet. It should
> be safe to fix this now before it is too late and we need to provide
> backward compatibility for the mt7623-eth compat string.
> 
> Reported-by: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
> Signed-off-by: John Crispin <john-Pj+rj9U5foFAfugRpC6u6w@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
