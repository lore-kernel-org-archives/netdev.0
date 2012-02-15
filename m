From: "N, Mugunthan V" <mugunthanvnm@ti.com>
Subject: RE: [PATCH 2/2] netdev: driver: ethernet: Add TI CPSW driver
Date: Wed, 15 Feb 2012 14:08:29 +0000
Message-ID: <EB1619762EAF8B4E97A227FB77B7E0293178AAD1@DBDE01.ent.ti.com>
References: <1329113061-13026-1-git-send-email-mugunthanvnm@ti.com>
	<1329113061-13026-3-git-send-email-mugunthanvnm@ti.com>
 <20120213093421.06ca60a7@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:47497 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758385Ab2BOOIe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 09:08:34 -0500
In-Reply-To: <20120213093421.06ca60a7@nehalam.linuxnetplumber.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger

> -----Original Message-----
> From: Stephen Hemminger [mailto:shemminger@vyatta.com]
> Sent: Monday, February 13, 2012 11:04 PM
> To: N, Mugunthan V
> Cc: netdev@vger.kernel.org; davem@davemloft.net
> Subject: Re: [PATCH 2/2] netdev: driver: ethernet: Add TI CPSW driver
> 

...

> 
> These stats belong in ethtool, not sysfs.
Yes, will remove this and will add it with ethtool support patches set.

With regards
Mugunthan V N
