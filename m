From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sch_htb: fix crash on init failure
Date: Tue, 29 Aug 2017 16:06:25 -0700 (PDT)
Message-ID: <20170829.160625.1623439754611810483.davem@davemloft.net>
References: <1504029487-7085-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, jiri@resnulli.us,
        roopa@cumulusnetworks.com
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41086 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751275AbdH2XG0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 19:06:26 -0400
In-Reply-To: <1504029487-7085-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I expect that you will resubmit all of these similar fixes as a patch
series after you have sorted everything out.

Correct?
