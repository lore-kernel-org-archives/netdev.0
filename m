From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH  v2 00/13] 2.6.20 Chelsio T3 RDMA Driver
Date: Sun, 3 Dec 2006 00:13:30 +0100
Message-ID: <20061202231329.GA10719@electric-eye.fr.zoreil.com>
References: <20061202224917.27014.15424.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rdreier@cisco.com, netdev@vger.kernel.org,
	openib-general@openib.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S936589AbWLBXQh@vger.kernel.org>
To: Steve Wise <swise@opengridcomputing.com>
Content-Disposition: inline
In-Reply-To: <20061202224917.27014.15424.stgit@dell3.ogc.int>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steve Wise <swise@opengridcomputing.com> :
[...]
> Version 2 changes:
> 
> - Make code sparse endian clean
> - Use IDRs for mapping QP and CQ IDs to structure pointers instead of arrays
> - Clean up confusing bitfields
> - Use random32() instead of local random function
> - Use krefs to track endpoint reference counts
> - Misc nits
> 
> -----
> 
> The following series implements the Chelsio T3 iWARP/RDMA Driver to
> be considered for inclusion in 2.6.20.  It depends on the Chelsio T3
> Ethernet Driver which is also under review now for 2.6.20. See:

I understood that Stephen expressed some doubts regarding the inclusion
of TOE enabled features.

Was his point addressed ?

-- 
Ueimor
