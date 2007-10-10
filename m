From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH net-2.6.24] network drivers: sparse warning fixes
Date: Tue, 09 Oct 2007 20:39:23 -0400
Message-ID: <470C1F3B.1020605@pobox.com>
References: <20071005171947.340f60af@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39075 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752476AbXJJAjZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2007 20:39:25 -0400
In-Reply-To: <20071005171947.340f60af@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Fix some of the easy warnings in network device drivers.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> ---
>  drivers/net/acenic.c         |   37 +++++++++++++++++++------------------
>  drivers/net/atl1/atl1_main.c |    5 +++--
>  drivers/net/dl2k.c           |    8 ++++----
>  drivers/net/e100.c           |    2 +-
>  drivers/net/hamachi.c        |    3 +--
>  drivers/net/natsemi.c        |    6 +++---
>  drivers/net/tehuti.c         |    4 +---
>  7 files changed, 32 insertions(+), 33 deletions(-)

applied


