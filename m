From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: define dst_pending_confirm as a bit in
 sctp_transport
Date: Tue, 21 Mar 2017 18:32:05 -0700 (PDT)
Message-ID: <20170321.183205.928220300578692007.davem@davemloft.net>
References: <b4390881b14adce583817529e5d58599acb5a8ee.1489836443.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com,
        vyasevich@gmail.com, ja@ssi.bg
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59684 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757982AbdCVBcH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 21:32:07 -0400
In-Reply-To: <b4390881b14adce583817529e5d58599acb5a8ee.1489836443.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Sat, 18 Mar 2017 19:27:23 +0800

> As tp->dst_pending_confirm's value can only be set 0 or 1, this
> patch is to change to define it as a bit instead of __u32.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied.
