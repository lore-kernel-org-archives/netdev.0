From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: napi cleanup
Date: Wed, 09 Aug 2017 22:42:17 -0700 (PDT)
Message-ID: <20170809.224217.394606585098072188.davem@davemloft.net>
References: <20170809023428.GA2054@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        intiyaz.basha@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51836 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750837AbdHJFmS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 01:42:18 -0400
In-Reply-To: <20170809023428.GA2054@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Tue, 8 Aug 2017 19:34:28 -0700

> From: Intiyaz Basha <intiyaz.basha@cavium.com>
> 
> Disable napi when interface is going down.
> Delete napi when destroying the interface.
> 
> Signed-off-by: Intiyaz Basha <intiyaz.basha@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>

Applied, thanks.
