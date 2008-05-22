From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ucc_geth_ethtool: Fix a few HW stats counters.
Date: Thu, 22 May 2008 14:06:07 -0400
Message-ID: <4835B60F.6070904@garzik.org>
References: <1210665877-6590-1-git-send-email-Joakim.Tjernlund@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, Li Yang <LeoLi@freescale.com>
To: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:35077 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756426AbYEVSGK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 14:06:10 -0400
In-Reply-To: <1210665877-6590-1-git-send-email-Joakim.Tjernlund@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joakim Tjernlund wrote:
> Noticed that ethtool -S didn't display tx-xxx-frames correctly.
> Fix it and a few others while I am there. Strangely, the
> rx-jumbo-frames counter still counts pkgs even though I think
> there isn't any packtes above 1518.
> 
> Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> ---
> 
> Havn't seen this go in or ACK/NACK. Resending.
> 
>  drivers/net/ucc_geth_ethtool.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)

still looking for maintainer's ack...


