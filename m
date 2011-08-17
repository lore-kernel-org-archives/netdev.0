From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH V2 net-next 0/3] bnx2x: Message logging cleanups
Date: Wed, 17 Aug 2011 16:42:08 +0300
Message-ID: <1313588528.7266.6.camel@lb-tlvb-eilong.il.broadcom.com>
References: <cover.1313360100.git.joe@perches.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Joe Perches" <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1027 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753363Ab1HQNmW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Aug 2011 09:42:22 -0400
In-Reply-To: <cover.1313360100.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-08-14 at 15:16 -0700, Joe Perches wrote: 
> Joe Perches (3):
>   bnx2x: Remove local defines for %pM and mac address
>   bnx2x: Coalesce pr_cont uses and fix DP typos
>   bnx2x: Use pr_fmt and message logging cleanups
> 
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x.h        |   67 ++++-----
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |   48 ++++---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    |    4 +-
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c    |    5 +-
>  .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |   23 ++--
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c   |  153 ++++++++++----------
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |   72 ++++-----
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c     |   67 ++++-----
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c  |   46 +++---
>  9 files changed, 244 insertions(+), 241 deletions(-)
> 

Thanks Joe, sorry it took a while - but ACK for all :)
Eilon


