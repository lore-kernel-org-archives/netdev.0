From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] sfc: make functions static
Date: Mon, 18 Oct 2010 18:05:18 +0100
Message-ID: <1287421518.2252.219.camel@achroite.uk.solarflarecom.com>
References: <20101018082731.36cd65e4@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Steve Hodgson <shodgson@solarflare.com>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:25206 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752191Ab0JRRFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 13:05:22 -0400
In-Reply-To: <20101018082731.36cd65e4@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-10-18 at 08:27 -0700, Stephen Hemminger wrote:
> Make local functions and variable static. Do some rearrangement
> of the string table stuff to put it where it gets used.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Acked-by: Ben Hutchings <bhutchings@solarflare.com>

We might have to change some of these back in future, but I suppose
there is no harm in making them static now.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

