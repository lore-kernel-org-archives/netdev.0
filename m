From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] qed: Replace memset with eth_zero_addr
Date: Mon, 16 Jan 2017 12:12:03 -0500 (EST)
Message-ID: <20170116.121203.1376051612147199138.davem@davemloft.net>
References: <20170116092435.GA2970@mystictot>
        <20170116.114606.1692928906878877115.davem@davemloft.net>
        <BL2PR07MB23069F2EFE839087FF63AC488D7D0@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mayhs11saini@gmail.com, netdev@vger.kernel.org
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44414 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750917AbdAPRMF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 12:12:05 -0500
In-Reply-To: <BL2PR07MB23069F2EFE839087FF63AC488D7D0@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Date: Mon, 16 Jan 2017 17:05:05 +0000

> Other than the fact these 2 patches change 2 different qed files,

That's what I was trying to hint at, the locations within the drivers
were the unique element.

> is there any significant difference between what each does?
> If not, why not simply do both in a single patch?

Also agreed.
