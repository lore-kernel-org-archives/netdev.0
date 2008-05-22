From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 01/16] sfc: Use mod_timer() to set expiry and add_timer()
 together
Date: Thu, 22 May 2008 06:01:07 -0400
Message-ID: <48354463.2030403@pobox.com>
References: <20080516201005.GS28241@solarflare.com> <20080516201357.GT28241@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40519 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761740AbYEVKBM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 06:01:12 -0400
In-Reply-To: <20080516201357.GT28241@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  drivers/net/sfc/boards.c |    9 +++------
>  1 files changed, 3 insertions(+), 6 deletions(-)

applied 1-16


