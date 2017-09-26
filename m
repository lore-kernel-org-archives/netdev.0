From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] liquidio: firmware loading
Date: Mon, 25 Sep 2017 20:26:27 -0700 (PDT)
Message-ID: <20170925.202627.1290726355878589610.davem@davemloft.net>
References: <20170923001206.GA1458@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        ricardo.farrington@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40442 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933685AbdIZD0a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 23:26:30 -0400
In-Reply-To: <20170923001206.GA1458@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Fri, 22 Sep 2017 17:12:06 -0700

> From: Rick Farrington <ricardo.farrington@cavium.com>
> 
> 1. Allow host driver parameter to override auto-loaded firmware (in flash).
> 2. Verify version of firmware that is auto-loaded from flash.
> 3. Change value of fw_type module parameter to reflect default firmware
>    image name that is loaded by host driver (in /sys/module/liquidio/...)

Series applied.
