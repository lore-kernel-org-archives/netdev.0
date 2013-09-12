From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [ethtool] ethtool: correct ixgbevf copyright date
Date: Thu, 12 Sep 2013 15:17:10 +0100
Message-ID: <1378995430.1531.7.camel@bwh-desktop.uk.level5networks.com>
References: <1377925372-13385-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jacob Keller <jacob.e.keller@intel.com>, <netdev@vger.kernel.org>,
	<gospo@redhat.com>, <sassmann@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:57194 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751736Ab3ILPx0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 11:53:26 -0400
In-Reply-To: <1377925372-13385-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-08-30 at 22:02 -0700, Jeff Kirsher wrote:
> From: Jacob Keller <jacob.e.keller@intel.com>
> 
> This patch corrects the copyright date of the ixgbevf code, which was only
> recently added.

Applied, thanks.

Ben.

> Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  ixgbevf.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/ixgbevf.c b/ixgbevf.c
> index dae1178..2a3aa6f 100644
> --- a/ixgbevf.c
> +++ b/ixgbevf.c
> @@ -1,4 +1,4 @@
> -/* Copyright (c) 2007 Intel Corporation */
> +/* Copyright (c) 2013 Intel Corporation */
>  #include <stdio.h>
>  #include "internal.h"
>  

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
