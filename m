From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] bridge: add support for PIM hello router
 ports
Date: Mon, 31 Oct 2016 16:18:56 -0400 (EDT)
Message-ID: <20161031.161856.1141050193618570322.davem@davemloft.net>
References: <1477916465-20406-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        dwalton@cumulusnetworks.com, stephen@networkplumber.org
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57434 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S946445AbcJaUS6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 16:18:58 -0400
In-Reply-To: <1477916465-20406-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Mon, 31 Oct 2016 13:21:01 +0100

> The first 3 patches of this set do minor cleanups and add some helpers to
> the PIM header file. Patch 4 adds a way to detect mcast router ports via
> PIM hello messages, they're marked as temporary and are not considered for
> querier. There's more detailed information in patch 4's commit message.

Looks pretty straight-forward and reasonable, series applied, thanks
Nikolay.
