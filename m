From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: moved ptp_enable to octeon_device
 structure
Date: Fri, 11 Aug 2017 15:03:02 -0700 (PDT)
Message-ID: <20170811.150302.1475829570890358255.davem@davemloft.net>
References: <20170811182209.GA1570@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        intiyaz.basha@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:32856 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754253AbdHKWDD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 18:03:03 -0400
In-Reply-To: <20170811182209.GA1570@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Fri, 11 Aug 2017 11:22:09 -0700

> From: Intiyaz Basha <intiyaz.basha@cavium.com>
> 
> ptp_enable was a global static variable.  Moved this global variable to
> octeon_device structure and removed extra device id check.
> 
> Signed-off-by: Intiyaz Basha <intiyaz.basha@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>

Applied, thanks.
