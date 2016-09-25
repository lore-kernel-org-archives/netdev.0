From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/7] ipv6 addrconf: enable use of
 proc_dointvec_minmax in addrconf_sysctl
Date: Sun, 25 Sep 2016 06:04:23 -0400 (EDT)
Message-ID: <20160925.060423.854801855957024790.davem@davemloft.net>
References: <20160925.053302.1895311145903319224.davem@davemloft.net>
        <1474797596-13320-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maze@google.com, netdev@vger.kernel.org, ek@google.com,
        lorenzo@google.com
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46702 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750727AbcIYKE1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 06:04:27 -0400
In-Reply-To: <1474797596-13320-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is missing an appropriate "[PATCH v2 0/7] ..." cover letter that
explains at a high level what this patch series is doing, why it is
doing it, and how it is doing it.

You'll have to submit a v3 with this fixed.
