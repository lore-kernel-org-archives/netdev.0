From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] net: dsa: Implement
 ndo_get_phys_port_name()
Date: Wed, 11 Jan 2017 09:59:17 -0500 (EST)
Message-ID: <20170111.095917.2134768534431547423.davem@davemloft.net>
References: <20170110203237.23907-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, jiri@resnulli.us
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50440 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938050AbdAKO7T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 09:59:19 -0500
In-Reply-To: <20170110203237.23907-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 10 Jan 2017 12:32:35 -0800

> This patch series implements ndo_get_phys_port_name() so we can revert
> ndo_get_phys_id() which was (ab)used in the DSA layer.

Series applied, thanks Florian.
