From: "N, Mugunthan V" <mugunthanvnm@ti.com>
Subject: RE: [Upstream PATCH 0/2] runtime PM support for cpsw and davinci
 mdio
Date: Tue, 17 Jul 2012 18:07:40 +0000
Message-ID: <EB1619762EAF8B4E97A227FB77B7E0293E9CBC9D@DBDE01.ent.ti.com>
References: <1342548353-12153-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:34576 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756241Ab2GQSHn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 14:07:43 -0400
In-Reply-To: <1342548353-12153-1-git-send-email-mugunthanvnm@ti.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: N, Mugunthan V
> Sent: Tuesday, July 17, 2012 11:36 PM
> To: netdev@vger.kernel.org
> Cc: davem@davemloft.net; N, Mugunthan V
> Subject: [Upstream PATCH 0/2] runtime PM support for cpsw and davinci
> mdio
> 
> This patch set adds support for runtime PM support for CPSW and Davinci
> MDIO
> drivers
> 
> Mugunthan V N (2):
>   driver: net: ethernet: davinci_mdio: runtime PM support
>   driver: net: ethernet: cpsw: runtime PM support
> 
>  drivers/net/ethernet/ti/cpsw.c         |   23 ++++++++++++++---------
>  drivers/net/ethernet/ti/davinci_mdio.c |   25 ++++++++++++------------
> -
>  2 files changed, 26 insertions(+), 22 deletions(-)

Please ignore this patch series as it was sent by mistake.
