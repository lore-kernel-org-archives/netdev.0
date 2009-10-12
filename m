From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [CAIF-RFC 1/8-v2] CAIF Protocol Stack
Date: Mon, 12 Oct 2009 01:20:36 -0700 (PDT)
Message-ID: <20091012.012036.266859347.davem@davemloft.net>
References: <1255095571-6501-1-git-send-email-sjur.brandeland@stericsson.com>
	<1255095571-6501-2-git-send-email-sjur.brandeland@stericsson.com>
	<4AD2E404.80704@babic.homelinux.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sjur.brandeland@stericsson.com, netdev@vger.kernel.org,
	kim.xx.lilliestierna@stericsson.com,
	christian.bejram@stericsson.com, daniel.martensson@stericsson.com
To: stefano.babic@babic.homelinux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59288
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754664AbZJLIUk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 04:20:40 -0400
In-Reply-To: <4AD2E404.80704@babic.homelinux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefano Babic <stefano.babic@babic.homelinux.org>
Date: Mon, 12 Oct 2009 10:08:36 +0200

> sjur.brandeland@stericsson.com wrote:
>> From: Sjur Braendeland <sjur.brandeland@stericsson.com>
>> @@ -0,0 +1,203 @@
>> +/*
>> + *	Copyright (C) ST-Ericsson AB 2009
>> + *
>> + *	CAIF Channel Configuration definitions.
>> + *
>> + *	Author: Sjur Brendeland/ sjur.brandeland@stericsson.com
>> + *
>> + *	License terms: GNU General Public License (GPL), version 2.
> 
> In the majority of linux drivers we find the following statements to set
> up the license terms :
> 
>  * This program is free software; you can redistribute it and/or modify
>  * it under the terms of the GNU General Public License as published by
>  * the Free Software Foundation; either version 2 of the License, or
>  * (at your option) any later version.

But Linus has stated explicitly that Linux itself falls under
GPL v2 and only v2.

See COPYING at the top level of the kernel sources.
