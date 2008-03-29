From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] Blackfin EMAC driver: finish removing remnants of
 old BF537_PORT_H option
Date: Fri, 28 Mar 2008 21:47:13 -0400
Message-ID: <47ED9FA1.8000000@garzik.org>
References: <> <1206580918-24720-2-git-send-email-cooloney@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mike Frysinger <vapier.adi@gmail.com>
To: Bryan Wu <cooloney@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48722 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753167AbYC2BrP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 21:47:15 -0400
In-Reply-To: <1206580918-24720-2-git-send-email-cooloney@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bryan Wu wrote:
> From: Mike Frysinger <vapier.adi@gmail.com>
> 
> Signed-off-by: Mike Frysinger <vapier.adi@gmail.com>
> Signed-off-by: Bryan Wu <cooloney@kernel.org>
> ---
>  arch/blackfin/mach-bf537/head.S |   12 ------------
>  drivers/net/Kconfig             |    2 +-
>  2 files changed, 1 insertions(+), 13 deletions(-)

ACK

please send via blackfin arch tree to Linus


