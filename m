From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: add missing strings in
 oct_dev_state_str array
Date: Sun, 06 Aug 2017 21:18:45 -0700 (PDT)
Message-ID: <20170806.211845.1612817234287514958.davem@davemloft.net>
References: <20170803200824.GA2312@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        intiyaz.basha@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50324 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751195AbdHGESq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 00:18:46 -0400
In-Reply-To: <20170803200824.GA2312@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Thu, 3 Aug 2017 13:08:24 -0700

> From: Intiyaz Basha <intiyaz.basha@cavium.com>
> 
> There's supposed to be a one-to-one correspondence between the 18 macros
> that #define the OCT_DEV states (in octeon_device.h) and the strings in the
> oct_dev_state_str array, but there are only 14 strings in the array.
> 
> Add the missing strings (so they become 18 in total), and also revise some
> incorrect/outdated text of existing strings.
> 
> Signed-off-by: Intiyaz Basha <intiyaz.basha@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>

Applied.
