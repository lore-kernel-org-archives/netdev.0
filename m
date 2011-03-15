From: Jamie Iles <jamie@jamieiles.com>
Subject: Re: [PATCHv2 3/9] macb: unify at91 and avr32 platform data
Date: Tue, 15 Mar 2011 11:34:27 +0000
Message-ID: <20110315113427.GE2914@pulham.picochip.com>
References: <1300184096-13937-1-git-send-email-jamie@jamieiles.com>
 <1300184096-13937-4-git-send-email-jamie@jamieiles.com>
 <87vczkmy94.fsf@macbook.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Iles <jamie@jamieiles.com>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, nicolas.ferre@atmel.com,
	plagnioj@jcrosoft.com
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:45038 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752047Ab1COLeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 07:34:31 -0400
Received: by bwz15 with SMTP id 15so438839bwz.19
        for <netdev@vger.kernel.org>; Tue, 15 Mar 2011 04:34:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <87vczkmy94.fsf@macbook.be.48ers.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Peter,

On Tue, Mar 15, 2011 at 12:14:31PM +0100, Peter Korsgaard wrote:
> >>>>> "Jamie" == Jamie Iles <jamie@jamieiles.com> writes:
>  Jamie> +++ b/include/linux/platform_data/macb.h
>  Jamie> @@ -0,0 +1,17 @@
>  Jamie> +/*
>  Jamie> + * Copyright (C) 2004-2006 Atmel Corporation
>  Jamie> + *
>  Jamie> + * This program is free software; you can redistribute it and/or modify
>  Jamie> + * it under the terms of the GNU General Public License version 2 as
>  Jamie> + * published by the Free Software Foundation.
>  Jamie> + */
>  Jamie> +#ifndef __MACB_PDATA_H__
>  Jamie> +#define __MACB_PDATA_H__
>  Jamie> +
>  Jamie> +struct eth_platform_data {
> 
> How about at the same time renaming it to something a bit less generic
> like macb_platform_data?

Yes, that's a fair point.

Jamie
