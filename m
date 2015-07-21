From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net v5 0/4] net: enable inband link state negotiation
 only when explicitly requested
Date: Tue, 21 Jul 2015 16:13:15 -0700 (PDT)
Message-ID: <20150721.161315.521614166214151302.davem@davemloft.net>
References: <1437439798-12622-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mxs-i6rsG8ix9II@public.gmane.org,
	arno-LkuqDEemtHBg9hUCZPvPmw@public.gmane.org, stsp-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org
To: f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1437439798-12622-1-git-send-email-f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Mon, 20 Jul 2015 17:49:54 -0700

> Changes in v5:
> 
> - removed an invalid use of the link_update callback in the SF2 driver
>   was appeared after merging "net: phy: fixed_phy: handle link-down case"
> 
> - reworded the commit message for patch 2 to make it clear what it fixes and
>   why this is required

Series applied, thanks Florian.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
