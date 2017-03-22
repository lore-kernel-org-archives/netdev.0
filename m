From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] r8152: check hw version first
Date: Tue, 21 Mar 2017 17:13:16 -0700 (PDT)
Message-ID: <20170321.171316.1092243230757127734.davem@davemloft.net>
References: <1394712342-15778-255-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
        linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58988 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757788AbdCVANV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 20:13:21 -0400
In-Reply-To: <1394712342-15778-255-Taiwan-albertk@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hayes Wang <hayeswang@realtek.com>
Date: Fri, 17 Mar 2017 11:20:13 +0800

> Check hw version first in probe(). Do nothing if the driver doesn't
> support the chip.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied, thanks.
