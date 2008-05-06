From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH v2.6.26] phylib: Fix some sparse warnings
Date: Tue, 06 May 2008 12:17:50 -0400
Message-ID: <482084AE.4000401@pobox.com>
References: <1209751251-25508-1-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45269 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763892AbYEFQRw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2008 12:17:52 -0400
In-Reply-To: <1209751251-25508-1-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Fleming wrote:
> Declared some things static, declared some things in the header.
> 
> Signed-off-by: Andy Fleming <afleming@freescale.com>
> ---
>  drivers/net/phy/phy.c |    2 +-
>  include/linux/phy.h   |    5 +++++
>  2 files changed, 6 insertions(+), 1 deletions(-)

applied


