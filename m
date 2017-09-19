From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: aquantia: default to no in config
Date: Tue, 19 Sep 2017 15:52:31 -0700 (PDT)
Message-ID: <20170919.155231.1474915838737685519.davem@davemloft.net>
References: <20170919224315.GA17797@shells.gnugeneration.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: vcaputo@pengaru.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49492 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751503AbdISWwc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 18:52:32 -0400
In-Reply-To: <20170919224315.GA17797@shells.gnugeneration.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vito Caputo <vcaputo@pengaru.com>
Date: Tue, 19 Sep 2017 15:43:15 -0700

> NET_VENDOR_AQUANTIA was "default y" for some reason, which seems
> obviously inappropriate.

It is appropriate.

We make all vendor guards default to yes.
