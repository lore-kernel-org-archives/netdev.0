From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next 00/12] net: bcmgenet: add support for GENETv5
Date: Mon, 13 Mar 2017 21:53:36 -0700 (PDT)
Message-ID: <20170313.215336.1855313796611091124.davem@davemloft.net>
References: <20170314004142.4746-1-opendmb@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        rafal-g1n6cQUeyibVItvQsEIGlw@public.gmane.org, xow-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, joel-U3u1mxZcP9KHXe+LvDLADg@public.gmane.org,
        jon.mason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        pgynther-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, jaedon.shin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: opendmb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170314004142.4746-1-opendmb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Doug Berger <opendmb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Mon, 13 Mar 2017 17:41:30 -0700

> This collection of patches contains changes related to adding
> support for the BCM7260, BCM7268, and BCM7271 devices that
> contain a new version of the GENET MAC IP block (v5) and a new
> fast ethernet (10/100BASE-T) internal PHY.
> 
> These patches were originally developed on top of the bug fixes
> of the "[PATCH v2 net 0/8] net: bcmgenet: minor bug fixes" patch
> set previously accepted into the net repository, but this
> submission is designed to be applied to the current net-next
> that does not yet include them. As a result there will be some
> merge conflicts that I would be happy to help resolve if desired.
> 
> Specifically, conflicts should occur with these patches from the
> minor bug fixes set:
> [PATCH v2 net 3/8] net: bcmgenet: reserved phy revisions must be checked first
> [PATCH v2 net 5/8] net: bcmgenet: synchronize irq0 status between the isr and task
> [PATCH v2 net 8/8] net: bcmgenet: decouple flow control from bcmgenet_tx_reclaim

Series applied, thanks Doug.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
