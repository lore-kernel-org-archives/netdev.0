From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tc-testing: fix arg to ip command: -s -> -n
Date: Tue, 31 Oct 2017 11:13:32 +0900 (KST)
Message-ID: <20171031.111332.1072048134747512833.davem@davemloft.net>
References: <20171030215922.14250-1-bjb@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        lucasb@mojatatu.com, aring@mojatatu.com, mrv@mojatatu.com,
        netdev@vger.kernel.org
To: bjb@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50782 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751956AbdJaCNg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 22:13:36 -0400
In-Reply-To: <20171030215922.14250-1-bjb@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Brenda J. Butler" <bjb@mojatatu.com>
Date: Mon, 30 Oct 2017 17:59:22 -0400

> Fixes: 31c2611b66e0 ("selftests: Introduce a new test case to tc testsuite")
> Fixes: 76b903ee198d ("selftests: Introduce tc testsuite")
> Signed-off-by: Brenda J. Butler <bjb@mojatatu.com>

Applied, thanks Brenda.
