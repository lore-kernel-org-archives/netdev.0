From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/7] qed/qede: Enhancements
Date: Thu, 27 Jul 2017 00:05:42 -0700 (PDT)
Message-ID: <20170727.000542.1623235616045337256.davem@davemloft.net>
References: <20170726130715.12976-1-manish.chopra@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yuval.Mintz@cavium.com,
        rahul.verma@cavium.com, sudarsana.kalluru@cavium.com
To: manish.chopra@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33622 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750836AbdG0HFn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 03:05:43 -0400
In-Reply-To: <20170726130715.12976-1-manish.chopra@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@cavium.com>
Date: Wed, 26 Jul 2017 06:07:08 -0700

> This patch series adds these below features support in qed/qede
> 
> 1) Ntuple filter configuration [via ethtool -n/N]
> 2) EEE (energy efficient ethernet) support [ethtool --set-eee/show-eee]
> 3) Coalescing configuration support for VFs [via ethtool -c/C]
> 
> Please consider applying this to "net-next"
> 
> V1->V2:
> * Fixes below Kbuild test robot warning.

Series applied, thanks.
