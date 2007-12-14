From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 8/8] gianfar: Magic Packet and suspend/resume support.
Date: Fri, 14 Dec 2007 15:24:29 -0500
Message-ID: <4762E67D.30600@pobox.com>
References: <20071212173607.GG5596@loki.buserror.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42971 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754316AbXLNUYj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2007 15:24:39 -0500
In-Reply-To: <20071212173607.GG5596@loki.buserror.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Scott Wood wrote:
> Signed-off-by: Scott Wood <scottwood@freescale.com>
> ---
> Jeff, can you ack this to go through Paul's tree
> (assuming nothing wrong with it)?
> 
>  drivers/net/gianfar.c         |  137 ++++++++++++++++++++++++++++++++++++++++-
>  drivers/net/gianfar.h         |   13 +++-
>  drivers/net/gianfar_ethtool.c |   41 ++++++++++++-
>  3 files changed, 185 insertions(+), 6 deletions(-)

ACK


