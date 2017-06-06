From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] hsr: fix coding style issues
Date: Tue, 06 Jun 2017 16:09:37 -0400 (EDT)
Message-ID: <20170606.160937.2113672006487973562.davem@davemloft.net>
References: <1496701907-29376-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arvid.brodin@alten.se, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: m-karicheri2@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38320 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751445AbdFFUJj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 16:09:39 -0400
In-Reply-To: <1496701907-29376-1-git-send-email-m-karicheri2@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please do not mix cleanups with legitimate bug fixes.  Also, when posting
a multi-patch series, you must always provide an appropriate "[PATCH 0/N]"
header posting that describes what you series is doing at a high level,
how it is doing it, and why it is doing it that way.

For this, submit the erroneous warning removal against 'net' as a single
patch.  And then once that propagates into the 'net-next' tree you can
submit the coding style cleanups against 'net-next', thanks.
