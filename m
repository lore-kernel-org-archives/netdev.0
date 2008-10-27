From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] dm9601: runtime mac address change support
Date: Mon, 27 Oct 2008 15:13:46 -0400
Message-ID: <490612EA.8070608@garzik.org>
References: <1224832107-6334-1-git-send-email-jacmet@sunsite.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:35236 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751891AbYJ0TNt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2008 15:13:49 -0400
In-Reply-To: <1224832107-6334-1-git-send-email-jacmet@sunsite.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Korsgaard wrote:
> Implement set_mac_address for runtime mac address change.
> 
> Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
> ---
>  drivers/net/usb/dm9601.c |   15 +++++++++++++++
>  1 files changed, 15 insertions(+), 0 deletions(-)

applied


