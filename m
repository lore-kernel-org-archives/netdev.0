From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 06/11] sfc: Add support for IEEE-1588 PTP
Date: Thu, 20 Sep 2012 08:59:00 +0200
Message-ID: <20120920065900.GB2349@netboy.at.omicron.at>
References: <1348081775.2636.15.camel@bwh-desktop.uk.solarflarecom.com>
 <1348082232.2636.21.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com,
	Rodolfo Giometti <giometti@enneenne.com>,
	Andrew Jackson <ajackson@solarflare.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:47238 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753040Ab2ITG7K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 02:59:10 -0400
Received: by weyx8 with SMTP id x8so1061496wey.19
        for <netdev@vger.kernel.org>; Wed, 19 Sep 2012 23:59:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1348082232.2636.21.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 19, 2012 at 08:17:12PM +0100, Ben Hutchings wrote:
> From: Stuart Hodgson <smhodgson@solarflare.com>
> 
> Add PTP IEEE-1588 support and make accesible via the PHC subsystem.
> 
> This work is based on prior code by Andrew Jackson
> 
> Signed-off-by: Stuart Hodgson <smhodgson@solarflare.com>
> [bwh:
>  - Add byte order conversion in efx_ptp_send_times()
>  - Simplify conversion of PPS event times
>  - Add the built-in vs module check to CONFIG_SFC_PTP dependencies]
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Acked-by: Richard Cochran <richardcochran@gmail.com>
