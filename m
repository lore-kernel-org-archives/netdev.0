From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: remove duplicate code
Date: Tue, 21 Mar 2017 17:43:33 -0700 (PDT)
Message-ID: <20170321.174333.223139892556654573.davem@davemloft.net>
References: <20170317175005.GA2276@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59230 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932742AbdCVAoc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 20:44:32 -0400
In-Reply-To: <20170317175005.GA2276@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Fri, 17 Mar 2017 10:50:05 -0700

> From: Satanand Burla <satananda.burla@cavium.com>
> 
> Remove code duplicated in PF and VF; define that code once only in a common
> header file included by PF and VF.
>  
> Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>

Applied.
