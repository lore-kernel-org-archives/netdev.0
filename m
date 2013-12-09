From: Chris Metcalf <cmetcalf@tilera.com>
Subject: Re: [PATCH net-next 14/16] tile_net: Implement the SIOCGHWTSTAMP
 ioctl
Date: Mon, 9 Dec 2013 14:39:49 -0500
Message-ID: <52A61C85.1060408@tilera.com>
References: <1386286632.1516.120.camel@bwh-desktop.uk.level5networks.com> <1386287834.1516.141.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	Richard Cochran <richardcochran@gmail.com>
To: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usmamail.tilera.com ([12.216.194.151]:26891 "EHLO
	USMAMAIL.TILERA.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932216Ab3LITjv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 14:39:51 -0500
In-Reply-To: <1386287834.1516.141.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/5/2013 6:57 PM, Ben Hutchings wrote:
> Compile-tested only (thanks to the kbuild test robot).
>
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  drivers/net/ethernet/tile/tilegx.c | 22 +++++++++++++++++++---
>  1 file changed, 19 insertions(+), 3 deletions(-)

Acked-by: Chris Metcalf <cmetcalf@tilera.com>

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com
