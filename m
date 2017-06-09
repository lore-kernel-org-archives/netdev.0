From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: disallow enabling firmware debug
 from a VF
Date: Fri, 09 Jun 2017 12:51:07 -0400 (EDT)
Message-ID: <20170609.125107.951779342423653233.davem@davemloft.net>
References: <20170609022036.GA1327@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34092 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751562AbdFIQvJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 12:51:09 -0400
In-Reply-To: <20170609022036.GA1327@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Thu, 8 Jun 2017 19:20:36 -0700

> From: Derek Chickles <derek.chickles@cavium.com>
> 
> Disallow enabling firmware debug from a VF.  Only PF is allowed to do that.
> 
> Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>

Applied.
