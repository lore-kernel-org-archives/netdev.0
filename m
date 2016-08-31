From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] ixgbe: Eliminate useless message and improve logic
Date: Tue, 30 Aug 2016 22:12:49 -0700 (PDT)
Message-ID: <20160830.221249.1061809744065434481.davem@davemloft.net>
References: <1472582023-53939-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mark.d.rustad@intel.com, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37696 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750708AbcHaFNI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 01:13:08 -0400
In-Reply-To: <1472582023-53939-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 30 Aug 2016 11:33:43 -0700

> From: Mark Rustad <mark.d.rustad@intel.com>
> 
> Remove a useless log message and improve the logic for setting
> a PHY address from the contents of the MNG_IF_SEL register.
> 
> Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
> Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
