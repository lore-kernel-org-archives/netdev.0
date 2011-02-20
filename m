From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH v2] net: dcb: match dcb_app protocol field with
 802.1Qaz spec
Date: Sat, 19 Feb 2011 19:00:59 -0800 (PST)
Message-ID: <20110219.190059.226793529.davem@davemloft.net>
References: <20110218233017.7419.32447.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shmulikr@broadcom.com, netdev@vger.kernel.org
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34996
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754892Ab1BTDAX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Feb 2011 22:00:23 -0500
In-Reply-To: <20110218233017.7419.32447.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Fri, 18 Feb 2011 15:30:17 -0800

> The dcb_app protocol field is a __u32 however the 802.1Qaz
> specification defines it as a 16 bit field. This patch brings
> the structure inline with the spec making it a __u16.
> 
> CC: Shmulik Ravid <shmulikr@broadcom.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied.
