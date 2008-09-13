From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 41/52] sfc: Add check for memory allocation failure in
 falcon_probe_nic()
Date: Sat, 13 Sep 2008 15:29:49 -0400
Message-ID: <48CC14AD.9070204@pobox.com>
References: <20080901111621.GT7908@solarflare.com> <20080903140750.GX7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50130 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753798AbYIMT3x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 15:29:53 -0400
In-Reply-To: <20080903140750.GX7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  drivers/net/sfc/falcon.c |    2 ++

applied 41-52, and the warning fix patch too


