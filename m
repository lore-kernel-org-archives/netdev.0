From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 3/4] i40evf: prevent VF close returning before state
 tranistions to DOWN
Date: Sat, 12 Aug 2017 13:01:59 -0700 (PDT)
Message-ID: <20170812.130159.609593547135212783.davem@davemloft.net>
References: <20170812110848.18264-1-jeffrey.t.kirsher@intel.com>
        <20170812110848.18264-4-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sudheer.mogilappagari@intel.com, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51586 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750973AbdHLUB7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 12 Aug 2017 16:01:59 -0400
In-Reply-To: <20170812110848.18264-4-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It seems like you sent two copies of this patch, one here which
seems part of a 4 patch series, and then another for the 03/15
copy.

Please sort that out.
