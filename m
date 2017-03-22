From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: fix Coverity scan errors
Date: Wed, 22 Mar 2017 11:48:44 -0700 (PDT)
Message-ID: <20170322.114844.1106672576138082542.davem@davemloft.net>
References: <20170321020448.GA3829@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        veerasenareddy.burru@cavium.com, stephen@networkplumber.org
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42982 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935317AbdCVSsu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 14:48:50 -0400
In-Reply-To: <20170321020448.GA3829@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Mon, 20 Mar 2017 19:04:48 -0700

> Fix Coverity scan errors by not dereferencing lio->glists_dma_base pointer
> if it's NULL.
> 
> See http://marc.info/?l=linux-netdev&m=149002294305614&w=2
> 
> Reported-by: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> Signed-off-by: VSR Burru <veerasenareddy.burru@cavium.com>

Applied.
