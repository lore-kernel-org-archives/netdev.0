From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: igmp: Allow mininum interval specification for igmp timers.
Date: Thu, 23 Sep 2010 21:38:23 -0700 (PDT)
Message-ID: <20100923.213823.137834706.davem@davemloft.net>
References: <alpine.DEB.2.00.1009221354410.32661@router.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rda-x0S3BwdUo6DQT0dZR+AlfA@public.gmane.org,
	dlstevens-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
To: cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.DEB.2.00.1009221354410.32661-sBS69tsa9Uj/9pzu0YdTqQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Date: Wed, 22 Sep 2010 13:59:30 -0500 (CDT)

> IGMP timers sometimes fire too rapidly due to randomization of the
> intervalsfrom 0 to max_delay in igmp_start_timer().
 ...
> Signed-off-by: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>


This change seems reasonable to me, what do you think David?
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
