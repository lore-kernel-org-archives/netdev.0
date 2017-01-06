From: David Miller <davem@davemloft.net>
Subject: Re: [next PATCH 00/11] ixgbe: Add support for writable pages and
 build_skb
Date: Fri, 06 Jan 2017 16:41:16 -0500 (EST)
Message-ID: <20170106.164116.1871412141301427533.davem@davemloft.net>
References: <20170106155448.1501.31298.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
        netdev@vger.kernel.org
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42420 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751460AbdAFVlS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 16:41:18 -0500
In-Reply-To: <20170106155448.1501.31298.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Fri, 06 Jan 2017 08:06:16 -0800

> The testing matrix for all of these patches is going to be pretty
> extensive.  Basically we want to test these patches on as many platforms
> and architectures as possible with as many features being toggled as
> possible including RSC, FCoE, SR-IOV, and Jumbo Frames all while receiving
> traffic.

Overall looks very nice to me.

I am assuming that I will get a formal submission once the necessary
amount of testing is performed.
