From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: removed check for queue size
 alignment
Date: Fri, 11 Aug 2017 13:56:15 -0700 (PDT)
Message-ID: <20170811.135615.1329251031265744199.davem@davemloft.net>
References: <20170809202804.GA1238@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        intiyaz.basha@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59460 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753256AbdHKU4Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 16:56:16 -0400
In-Reply-To: <20170809202804.GA1238@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Wed, 9 Aug 2017 13:28:04 -0700

> From: Intiyaz Basha <intiyaz.basha@cavium.com>
> 
> There is no restriction on queue size alignment.  Hence removing check for
> valid queue size.
> 
> Signed-off-by: Intiyaz Basha <intiyaz.basha@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>

Applied.
