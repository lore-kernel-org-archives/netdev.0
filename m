From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 4/4] parisc: Update defconfigs which were missing
 CONFIG_NET.
Date: Wed, 24 Sep 2014 13:39:09 -0700
Message-ID: <20140924203909.GB27927@roeck-us.net>
References: <20140924.144929.1831753286382773236.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:46767 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750871AbaIXUjO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 16:39:14 -0400
Received: by mail-pa0-f54.google.com with SMTP id fb1so9408929pad.41
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 13:39:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140924.144929.1831753286382773236.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 24, 2014 at 02:49:29PM -0400, David Miller wrote:
> 
> Commit df568d8e ("scsi: Use 'depends' with LIBFC instead of
> 'select'.")  removed what happened to be the only instance of 'select
> NET'. Defconfigs that were relying on the select now lack networking
> support.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  arch/parisc/configs/a500_defconfig | 1 +

My list also includes c8000_defconfig.

Guenter
