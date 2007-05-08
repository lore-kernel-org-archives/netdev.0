From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] sky2: re-enable 88E8056 for most motherboards
Date: Tue, 08 May 2007 01:23:32 -0400
Message-ID: <46400954.3020300@garzik.org>
References: <20070430142349.79754c1b@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org,
	Francois SIMOND <curio@free.fr>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54442 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967910AbXEHFXf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 01:23:35 -0400
In-Reply-To: <20070430142349.79754c1b@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> This fixes the regression in 2.6.21 for users with 88e8056 on motherboard.
> Allow all but the Gigabyte motherboard has some unresolved bus problems.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> ---
>  drivers/net/sky2.c |   17 +++++++++++++----
>  1 file changed, 13 insertions(+), 4 deletions(-)

applied


