From: David Miller <davem@davemloft.net>
Subject: Re: Resend all vs. individual patch updates
Date: Sun, 02 Apr 2017 14:58:49 -0700 (PDT)
Message-ID: <20170402.145849.1407671421945961076.davem@davemloft.net>
References: <1491168068.26047.17.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39648 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750966AbdDBV64 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 2 Apr 2017 17:58:56 -0400
In-Reply-To: <1491168068.26047.17.camel@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Mon, 03 Apr 2017 07:21:08 +1000

> What is your preference when a couple of patches in a series of about a
> dozen get updated as a result of reviews ? Just send updates to those
> few or resend the whole series ?
> 
> In the latter case I'll wait a bit longer for more comments.

Always resend all.
