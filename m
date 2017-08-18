From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] liquidio: initialization fixes for
 embedded firmware
Date: Fri, 18 Aug 2017 10:15:04 -0700 (PDT)
Message-ID: <20170818.101504.1956453381393117773.davem@davemloft.net>
References: <20170818061037.GA4024@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        ricardo.farrington@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56728 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751108AbdHRRPL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 13:15:11 -0400
In-Reply-To: <20170818061037.GA4024@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Thu, 17 Aug 2017 23:10:37 -0700

> From: Rick Farrington <ricardo.farrington@cavium.com>
> 
> Fix problems when using an adapter w/embedded f/w (param "fw_type=none").
> 
> 1. Add support for PF FLR when exiting.
> 2. Skip some initialization (don't try to load f/w, activate consoles).
> 3. Issue credits BEFORE enabling DROQs.

Series applied, thanks.
