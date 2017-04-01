From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8152: The Microsoft Surface docks also use R8152 v2
Date: Sat, 01 Apr 2017 12:20:06 -0700 (PDT)
Message-ID: <20170401.122006.567219749959358946.davem@davemloft.net>
References: <20170328.064215.1055636797214516339.rene@exactcode.com>
        <1490893565.24247.9.camel@redhat.com>
        <20170328.075651.1863370888471526975.rene@exactcode.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: dcbw@redhat.com, netdev@vger.kernel.org, nic_swsd@realtek.com
To: rene@exactcode.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56918 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751804AbdDATUJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Apr 2017 15:20:09 -0400
In-Reply-To: <20170328.075651.1863370888471526975.rene@exactcode.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rene Rebe <rene@exactcode.com>
Date: Tue, 28 Mar 2017 07:56:51 +0200 (CEST)

> Without this the generic cdc_ether grabs the device,
> and does not really work.
> 
> Signed-off-by: René Rebe <rene@exactcode.de>

Applied, thank you.
