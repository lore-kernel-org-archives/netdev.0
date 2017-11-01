From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tc-testing: gitignore, ignore standard python
 artifacts
Date: Wed, 01 Nov 2017 11:05:38 +0900 (KST)
Message-ID: <20171101.110538.233659817590824382.davem@davemloft.net>
References: <20171031182654.9674-1-bjb@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        chrism@mellanox.com, lucasb@mojatatu.com, aring@mojatatu.com,
        mrv@mojatatu.com, netdev@vger.kernel.org
To: bjb@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43680 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932210AbdKACFm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 22:05:42 -0400
In-Reply-To: <20171031182654.9674-1-bjb@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Brenda J. Butler" <bjb@mojatatu.com>
Date: Tue, 31 Oct 2017 14:26:54 -0400

> Ignore .pyc files, "python compiled" files, that get created
> when a python script is run.  They should never be committed.
> 
> Signed-off-by: Brenda J. Butler <bjb@mojatatu.com>

Applied.
