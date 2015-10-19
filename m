From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2 1/1] net: phy: bcm-phy-lib: Fix module license issue
Date: Sun, 18 Oct 2015 19:35:32 -0700 (PDT)
Message-ID: <20151018.193532.1720599526781320491.davem@davemloft.net>
References: <1444930633-23314-1-git-send-email-arunp@broadcom.com>
	<1444930633-23314-2-git-send-email-arunp@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org
To: arunp-dY08KVG/lbpWk0Htik3J/w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1444930633-23314-2-git-send-email-arunp-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Arun Parameswaran <arunp-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Date: Thu, 15 Oct 2015 10:37:13 -0700

> The 'bcm-phy-lib.c', added as a part of the commit
> "net: phy: Add Broadcom phy library for common interfaces"
> was missing the module license. This was causing an issue
> when the library is built as a module; "module license
> 'unspecified' taints kernel".
> 
> This patch fixes the issue by adding the module license,
> author and description to the bcm-phy-lib.c file.
> 
> Fixes: a1cba5613edf5 ("net: phy: Add Broadcom phy library for
> common interfaces")
> Signed-off-by: Arun Parameswaran <arunp-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
