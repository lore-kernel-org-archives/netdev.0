From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH ethtool] marvell chip decode formatting
Date: Fri, 09 Feb 2007 16:32:56 -0500
Message-ID: <45CCE888.3050106@garzik.org>
References: <20070131162346.48d796d4@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60478 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752515AbXBIVc6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Feb 2007 16:32:58 -0500
In-Reply-To: <20070131162346.48d796d4@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Fix some typo's and formatting on Marvell ethtool output.
> If sync transmit queue is not used, don't print settings.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> ---
>  marvell.c |   37 ++++++++++++++++++++++++-------------
>  1 files changed, 24 insertions(+), 13 deletions(-)

applied

