From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/8] [Blackfin] EMAC driver: shorten the mdelay value
 to solve netperf performance issue
Date: Wed, 30 Jan 2008 04:00:59 -0500
Message-ID: <47A03CCB.8080500@garzik.org>
References: <1201683148-23931-1-git-send-email-bryan.wu@analog.com> <1201683148-23931-2-git-send-email-bryan.wu@analog.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Bryan Wu <bryan.wu@analog.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59303 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758929AbYA3JBD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 04:01:03 -0500
In-Reply-To: <1201683148-23931-2-git-send-email-bryan.wu@analog.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bryan Wu wrote:
> Signed-off-by: Bryan Wu <bryan.wu@analog.com>
> ---
>  drivers/net/bfin_mac.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)

applied 1-8


