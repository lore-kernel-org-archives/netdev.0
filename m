From: David Miller <davem@davemloft.net>
Subject: new patch state in patchwork...
Date: Mon, 30 Jan 2017 15:38:19 -0500 (EST)
Message-ID: <20170130.153819.2199482108994890531.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netfilter-devel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39034 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752695AbdA3Uix (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 15:38:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I noticed there is a new state "Needs Review / ACK" in patchwork.

I am going to use this for situations where I am explicitly waiting
either for a maintainer, or someone referenced directly in the patch
discussion, to review and ACK/NACK the change.

Just FYI...
