From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp_bbr: add a state transition diagram and
 accompanying comment
Date: Sat, 29 Oct 2016 17:13:23 -0400 (EDT)
Message-ID: <20161029.171323.289633496956132261.davem@davemloft.net>
References: <1477589197-18123-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, edumazet@google.com,
        soheil@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52980 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751055AbcJ2VN0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2016 17:13:26 -0400
In-Reply-To: <1477589197-18123-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Thu, 27 Oct 2016 13:26:37 -0400

> Document the possible state transitions for a BBR flow, and also add a
> prose summary of the state machine, covering the life of a typical BBR
> flow.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>

Applied.
