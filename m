From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 0/5] cxgb4: Fix for PCI passthrough and some Misc.
 fixes
Date: Tue, 01 Jul 2014 18:56:34 -0700 (PDT)
Message-ID: <20140701.185634.648448705735327396.davem@davemloft.net>
References: <1403877231-8661-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org,
	leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1403877231-8661-1-git-send-email-hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Date: Fri, 27 Jun 2014 19:23:46 +0530

> This patch series fixes probe failure in VM when PF is exposed through PCI
> Passthrough. Adds support to use firmware interface to get BAR0 value.
> Replace the backdoor mechanism to access the HW memory with PCIe Window method
> which fixes memory I/O. Also adds device ID of few more adapters for cxgb4 and
> cxgb4vf driver.
> 
> The patches series is created against 'net-next' tree.
> And includes patches on cxgb4, cxgb4vf and iw_cxgb4 driver.
> 
> Since this patch-series contains mainly cxgb4 related changes, we would like to
> request this patch series to get merged via David Miller's 'net-next' tree.
> 
> We have included all the maintainers of respective drivers. Kindly review the
> change and let us know in case of any review comments.

Series applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
