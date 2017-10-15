From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/4] tc-testing: Test suite updates
Date: Sat, 14 Oct 2017 18:48:09 -0700 (PDT)
Message-ID: <20171014.184809.660454619715492196.davem@davemloft.net>
References: <1507931485-1814-1-git-send-email-lucasb@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        jhs@mojatatu.com, aring@mojatatu.com, mrv@mojatatu.com
To: lucasb@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38430 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751165AbdJOBsK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Oct 2017 21:48:10 -0400
In-Reply-To: <1507931485-1814-1-git-send-email-lucasb@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lucas Bates <lucasb@mojatatu.com>
Date: Fri, 13 Oct 2017 17:51:21 -0400

> This patch series is a roundup of changes to the tc-testing
> suite:
> 
>  - Add test cases for police and mirred modules and some coverage
>    in already-submitted test categories
>  - Break the test case files down into more user-friendly sizes
>  - Bug fix to the tdc.py script's handling of the -l argument
> 
> v2: fix the lack of final newlines in two new files (thanks David)

Series applied, thanks for fixing that up.
