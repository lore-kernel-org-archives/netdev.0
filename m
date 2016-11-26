From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethtool: don't require CAP_NET_ADMIN for
 ETHTOOL_GLINKSETTINGS
Date: Fri, 25 Nov 2016 20:23:45 -0500 (EST)
Message-ID: <20161125.202345.843230215255119728.davem@davemloft.net>
References: <20161124095506.25791-1-mlichvar@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, decot@googlers.com
To: mlichvar@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58324 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751968AbcKZBXt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 20:23:49 -0500
In-Reply-To: <20161124095506.25791-1-mlichvar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Miroslav Lichvar <mlichvar@redhat.com>
Date: Thu, 24 Nov 2016 10:55:06 +0100

> The ETHTOOL_GLINKSETTINGS command is deprecating the ETHTOOL_GSET
> command and likewise it shouldn't require the CAP_NET_ADMIN capability.
> 
> Signed-off-by: Miroslav Lichvar <mlichvar@redhat.com>

Good catch, applied, thanks.
