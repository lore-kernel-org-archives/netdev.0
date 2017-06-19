From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH v2 net-next 0/7] qed*: RDMA and infrastructure for iWARP
Date: Mon, 19 Jun 2017 04:36:31 +0200
Message-ID: <20170619023631.GB13292@lunn.ch>
References: <20170618115035.2156-1-Yuval.Mintz@cavium.com>
 <20170618.122901.124548969151925362.davem@davemloft.net>
 <BLUPR0701MB20047CD16002072436A61EA38DC70@BLUPR0701MB2004.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "Kalderon, Michal" <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Mintz, Yuval" <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <BLUPR0701MB20047CD16002072436A61EA38DC70-v5ruerSQ/oj1oiTf6dR/AE5OhdzP3rhOnBOFsp37pqbUKgpGm//BTAC/G2K4zDHf@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> I can't really say I understand who would benefit from adding 
> "while at it remove redundant inclusion of header file"
> to the commit log message [And even less from splitting this into its own patch].

Part of it is trust.

If you say you are just renaming, not making any change, reviewers
will not look too deep at the change. But if you do make a change, but
not say anything about it, we loose trust in what you are saying.

    Andrew

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
