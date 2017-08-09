From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: fix wrong info about vf rx/tx ring
 parameters reported to ethtool
Date: Tue, 08 Aug 2017 18:10:07 -0700 (PDT)
Message-ID: <20170808.181007.1444786901566059012.davem@davemloft.net>
References: <20170807173900.GA1078@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        intiyaz.basha@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58286 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751919AbdHIBKI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 21:10:08 -0400
In-Reply-To: <20170807173900.GA1078@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Mon, 7 Aug 2017 10:39:00 -0700

> From: Intiyaz Basha <intiyaz.basha@cavium.com>
> 
> Information reported to ethtool about vf rx/tx ring parameters is wrong.
> Fix it by adding the missing initializations.
> 
> Signed-off-by: Intiyaz Basha <intiyaz.basha@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>

Applied.
