From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 05/10] pcmcia net: use roundup_pow_of_two() macro instead
 of grotesque loop
Date: Mon, 17 Dec 2007 20:18:06 -0500
Message-ID: <47671FCE.20001@garzik.org>
References: <200712140002.lBE02u8R025523@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rpjday@crashcourse.ca,
	linux@dominikbrodowski.net
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34175 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760737AbXLRBSJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 20:18:09 -0500
In-Reply-To: <200712140002.lBE02u8R025523@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: "Robert P. J. Day" <rpjday@crashcourse.ca>
> 
> Signed-off-by: Robert P. J. Day <rpjday@crashcourse.ca>
> Cc: Jeff Garzik <jeff@garzik.org>
> Cc: Dominik Brodowski <linux@dominikbrodowski.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/pcmcia/pcnet_cs.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

applied #upstream


