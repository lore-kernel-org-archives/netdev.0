From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] genetlink improvements
Date: Thu, 27 Oct 2016 16:16:39 -0400 (EDT)
Message-ID: <20161027.161639.1547619291092385890.davem@davemloft.net>
References: <1477312805-7110-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33556 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750823AbcJ0UQl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 16:16:41 -0400
In-Reply-To: <1477312805-7110-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Mon, 24 Oct 2016 14:40:00 +0200

> This series contains some generic netlink improvements, making
> the API safer to use, and making the function pointers in the
> family struct safer by allowing it to be __ro_after_init.

Looks great, series applied, thanks!
