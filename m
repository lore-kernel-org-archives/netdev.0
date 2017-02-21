From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC v3 8/8] xdp: Cleanup after API changes
Date: Tue, 21 Feb 2017 16:06:18 -0500 (EST)
Message-ID: <20170221.160618.716814569978889472.davem@davemloft.net>
References: <20170221193417.3641224-1-tom@herbertland.com>
        <20170221193417.3641224-9-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60602 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751161AbdBUVGX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 16:06:23 -0500
In-Reply-To: <20170221193417.3641224-9-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Tue, 21 Feb 2017 11:34:17 -0800

>   - Change trace_xdp_hook_exception to trace_xdp_exception

Just give it this final name in patch #1 where you introduce it.
