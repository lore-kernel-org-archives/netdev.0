From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] CDC NCM: Add mising short packet in cdc_ncm driver
Date: Thu, 12 May 2011 15:30:12 -0700 (PDT)
Message-ID: <20110512.153012.112604973.davem@davemloft.net>
References: <y>
	<1304686890-2543-1-git-send-email-alexey.orishko@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org, gregkh@suse.de,
	alexey.orishko@stericsson.com
To: alexey.orishko@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42032
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756563Ab1ELWao (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 18:30:44 -0400
In-Reply-To: <1304686890-2543-1-git-send-email-alexey.orishko@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Orishko <alexey.orishko@gmail.com>
Date: Fri,  6 May 2011 15:01:30 +0200

> Changes:
> - while making NTB, driver shall check if device dwNtbOutMaxSize is higher than
>  host value and shall add a short packet if this is the case
> - previous temporary patch for this issue is replaced by this one
> 
> Signed-off-by: Alexey Orishko <alexey.orishko@stericsson.com>

Applied to net-next-2.6, thanks.
