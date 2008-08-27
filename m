From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch for 2.6.27? 2/5] drivers/net/skfp/ess.c: fix compile warnings
Date: Wed, 27 Aug 2008 05:37:08 -0400
Message-ID: <48B52044.9090102@garzik.org>
References: <200808202334.m7KNYZMk005029@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tiwai@suse.de
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59080 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753865AbYH0JhL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 05:37:11 -0400
In-Reply-To: <200808202334.m7KNYZMk005029@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Takashi Iwai <tiwai@suse.de>
> 
>   CC [M]  drivers/net/skfp/ess.o
> drivers/net/skfp/ess.c: In function 'ess_send_response':
> drivers/net/skfp/ess.c:513: warning: cast from pointer to integer of different size
> drivers/net/skfp/ess.c: In function 'ess_send_alc_req':
> drivers/net/skfp/ess.c:609: warning: cast from pointer to integer of different size
> drivers/net/skfp/ess.c:639: warning: cast from pointer to integer of different size
> 
> Signed-off-by: Takashi Iwai <tiwai@suse.de>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/skfp/ess.c |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)

applied


