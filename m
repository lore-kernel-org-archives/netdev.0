From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V4 00/10] liquidio CN23XX support
Date: Wed, 31 Aug 2016 14:13:04 -0700 (PDT)
Message-ID: <20160831.141304.936698663361263678.davem@davemloft.net>
References: <1472666609-19503-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rvatsavayi@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48432 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753880AbcHaVNG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 17:13:06 -0400
In-Reply-To: <1472666609-19503-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Date: Wed, 31 Aug 2016 11:03:19 -0700

> Following patchset adds support for new device "CN23XX" in
> liquidio family of adapters. As adviced by you I have split
> the previous V3 patch of 18 patches into two halves. This
> first patchset has first 10 patches, which are tested against
> net-next. I will post the second half after this one.
> 
> This V4 patch also addressed all the comments from previous
> submission:
> 1) Avoid busy loop while reading registers.
> 2) Other minor comments about debug messages and constants.
> 
> Please apply patches in following order as some of the
> patches depend on earlier patches.

Series applied, thanks.
