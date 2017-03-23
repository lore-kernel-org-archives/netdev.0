From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: vmxnet3: use new api
 ethtool_{get|set}_link_ksettings
Date: Wed, 22 Mar 2017 19:27:42 -0700 (PDT)
Message-ID: <20170322.192742.1663850705884902499.davem@davemloft.net>
References: <1490167677-27130-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: skhare@vmware.com, pv-drivers@vmware.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46926 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755939AbdCWC1o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 22:27:44 -0400
In-Reply-To: <1490167677-27130-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Wed, 22 Mar 2017 08:27:57 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
