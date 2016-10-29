From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2] rocker: set physical device for port
 netdevice
Date: Sat, 29 Oct 2016 17:16:30 -0400 (EDT)
Message-ID: <20161029.171630.569218699820068623.davem@davemloft.net>
References: <1477600342-2752-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53018 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751055AbcJ2VQc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2016 17:16:32 -0400
In-Reply-To: <1477600342-2752-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 27 Oct 2016 22:32:22 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Do this so the sysfs has "device" link correctly set.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
> v1->v2:
>  - make pdev non-const as pointerd out by kbuild test robot

Applied, thanks Jiri.
