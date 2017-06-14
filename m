From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: fix VF driver off-by-one bug when
 setting ethtool -C ethX rx-frames
Date: Wed, 14 Jun 2017 15:42:57 -0400 (EDT)
Message-ID: <20170614.154257.440660640094291568.davem@davemloft.net>
References: <20170614161131.GA1383@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        weilin.chang@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54774 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752008AbdFNTnB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 15:43:01 -0400
In-Reply-To: <20170614161131.GA1383@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Wed, 14 Jun 2017 09:11:31 -0700

> From: Weilin Chang <weilin.chang@cavium.com>
> 
> Signed-off-by: Weilin Chang <weilin.chang@cavium.com>
> Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>

Applied.
