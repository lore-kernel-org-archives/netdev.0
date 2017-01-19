From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6 00/13] net: ethernet: aquantia: Add AQtion 2.5/5 GB
 NIC driver
Date: Thu, 19 Jan 2017 11:55:01 -0500 (EST)
Message-ID: <20170119.115501.1276899174376549958.davem@davemloft.net>
References: <cover.1484788010.git.vomlehn@texas.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vomlehn@texas.net,
        Simon.Edelhaus@aquantia.com, Dmitrii.Tarakanov@aquantia.com,
        Pavel.Belous@aquantia.com
To: Alexander.Loktionov@aquantia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60728 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753532AbdASQzG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 11:55:06 -0500
In-Reply-To: <cover.1484788010.git.vomlehn@texas.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Date: Wed, 18 Jan 2017 17:07:51 -0800

> From: David VomLehn <vomlehn@texas.net>
> 
> This series introduces the AQtion NIC driver for the aQuantia
> AQC107/AQC108 network devices.
> 
> This series introduces the AQtion NIC driver for the aQuantia
> AQC107/AQC108 network devices.

You don't need to say this twice :-)

Also, please incorporate the fix posted by the kbuild test robot.
