From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tc-testing: better test case file error
 reporting
Date: Wed, 01 Nov 2017 11:06:42 +0900 (KST)
Message-ID: <20171101.110642.613041953759462625.davem@davemloft.net>
References: <20171031182903.9885-1-bjb@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        chrism@mellanox.com, lucasb@mojatatu.com, aring@mojatatu.com,
        mrv@mojatatu.com, netdev@vger.kernel.org
To: bjb@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43730 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932210AbdKACGq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 22:06:46 -0400
In-Reply-To: <20171031182903.9885-1-bjb@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Brenda J. Butler" <bjb@mojatatu.com>
Date: Tue, 31 Oct 2017 14:29:03 -0400

> tdc.py reads a bunch of test cases in json files.  When a json file
> cannot be parsed, tdc just exits and does not run any tests.
> 
> This patch will cause tdc to print a message with the file name and
> line number, then that file will be ignored and the rest of the tests
> will be processed.
> 
> Signed-off-by: Brenda J. Butler <bjb@mojatatu.com>

Applied.
