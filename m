From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: rename *_sequence_number() to
 *_seq_and_tsoff()
Date: Thu, 09 Mar 2017 18:26:08 -0800 (PST)
Message-ID: <20170309.182608.2233672800000076648.davem@davemloft.net>
References: <1489056835-1128-1-git-send-email-alexey.kodanev@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: alexey.kodanev@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48244 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751013AbdCJC0K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 21:26:10 -0500
In-Reply-To: <1489056835-1128-1-git-send-email-alexey.kodanev@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Kodanev <alexey.kodanev@oracle.com>
Date: Thu,  9 Mar 2017 13:53:55 +0300

> The functions that are returning tcp sequence number also setup
> TS offset value, so rename them to better describe their purpose.
> 
> No functional changes in this patch.
> 
> Suggested-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Alexey Kodanev <alexey.kodanev@oracle.com>

Applied, thanks.
