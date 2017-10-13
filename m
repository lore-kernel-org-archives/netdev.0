From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] tc-testing: Test suite updates
Date: Thu, 12 Oct 2017 22:31:41 -0700 (PDT)
Message-ID: <20171012.223141.649885637634633495.davem@davemloft.net>
References: <1507756614-30333-1-git-send-email-lucasb@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        jhs@mojatatu.com, aring@mojatatu.com, mrv@mojatatu.com
To: lucasb@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35240 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751353AbdJMFbm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 01:31:42 -0400
In-Reply-To: <1507756614-30333-1-git-send-email-lucasb@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lucas Bates <lucasb@mojatatu.com>
Date: Wed, 11 Oct 2017 17:16:50 -0400

> This patch series is a roundup of changes to the tc-testing
> suite:
> 
>  - Add test cases for police and mirred modules and some coverage
>    in already-submitted test categories
>  - Break the test case files down into more user-friendly sizes
>  - Bug fix to the tdc.py script's handling of the -l argument

Some of the newly added files lack final newlines, and as you can
see in the git patch output a warning is generated.

Please fix this up and resubmit.

Thanks.
