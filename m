From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: greth: Utilize of_get_mac_address()
Date: Wed, 22 Mar 2017 12:01:00 -0700 (PDT)
Message-ID: <20170322.120100.1183221600089753161.davem@davemloft.net>
References: <20170321102438.31382-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andreas@gaisler.com, netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43164 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751769AbdCVTBC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 15:01:02 -0400
In-Reply-To: <20170321102438.31382-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Tue, 21 Mar 2017 11:24:38 +0100

> Do not open code getting the MAC address exclusively from the
> "local-mac-address" property, but instead use of_get_mac_address() which
> looks up the MAC address using the 3 typical property names.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied, thank you.
