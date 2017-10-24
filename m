From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cdc_ether: flag the Huawei ME906/ME909 as WWAN
Date: Tue, 24 Oct 2017 18:35:11 +0900 (KST)
Message-ID: <20171024.183511.1650313066583694272.davem@davemloft.net>
References: <20171023151641.5674-1-aleksander@aleksander.es>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        oliver@neukum.org, linux-kernel@vger.kernel.org
To: aleksander@aleksander.es
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58220 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932241AbdJXJfP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 05:35:15 -0400
In-Reply-To: <20171023151641.5674-1-aleksander@aleksander.es>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aleksander Morgado <aleksander@aleksander.es>
Date: Mon, 23 Oct 2017 17:16:41 +0200

> The Huawei ME906 (12d1:15c1) comes with a standard ECM interface that
> requires management via AT commands sent over one of the control TTYs
> (e.g. connected with AT^NDISDUP).
> 
> Signed-off-by: Aleksander Morgado <aleksander@aleksander.es>

Applied.
