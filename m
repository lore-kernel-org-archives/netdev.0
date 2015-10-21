From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2 0/2] net, phy, smsc: add posibility to disable
 energy detect mode
Date: Wed, 21 Oct 2015 06:42:58 -0700 (PDT)
Message-ID: <20151021.064258.171088607791931068.davem@davemloft.net>
References: <1445054676-21523-1-git-send-email-hs@denx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	balbi-l0cyMroinI0@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	Georg.Soffel-k21M0aUVSxZWk0Htik3J/w@public.gmane.org, tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org,
	lsorense-1wCw9BSqJbv44Nm34jS7GywD8/FfD2ys@public.gmane.org, mugunthanvnm-l0cyMroinI0@public.gmane.org,
	richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: hs-ynQEQJNshbs@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1445054676-21523-1-git-send-email-hs-ynQEQJNshbs@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Heiko Schocher <hs-ynQEQJNshbs@public.gmane.org>
Date: Sat, 17 Oct 2015 06:04:34 +0200

> On some boards the energy enable detect mode leads in
> trouble with some switches, so make the enabling of
> this mode configurable through DT.
> Therefore the property "smsc,disable-energy-detect" is
> introduced.
> 
> Patch 1 introduces phy-handle support for the ti,cpsw
> driver. This is needed now for the smsc phy.
> 
> Patch 2 adds the disable energy mode functionality
> to the smsc phy

Series applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
