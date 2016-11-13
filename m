From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] mlxsw: reg: Fix pwm_frequency field size in
 MFCR register
Date: Sun, 13 Nov 2016 12:52:36 -0500 (EST)
Message-ID: <20161113.125236.855229819751470828.davem@davemloft.net>
References: <1478859773-3013-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44550 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753413AbcKMRxf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 12:53:35 -0500
In-Reply-To: <1478859773-3013-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 11 Nov 2016 11:22:53 +0100

> From: Jiri Pirko <jiri@mellanox.com>
> 
> The field is 7bit long. Fix it.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied.
