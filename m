From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tc-testing: better check if thing is list
Date: Wed, 01 Nov 2017 11:06:35 +0900 (KST)
Message-ID: <20171101.110635.1013667286416164554.davem@davemloft.net>
References: <20171031182835.9834-1-bjb@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        chrism@mellanox.com, lucasb@mojatatu.com, aring@mojatatu.com,
        mrv@mojatatu.com, netdev@vger.kernel.org
To: bjb@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43718 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932210AbdKACGk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 22:06:40 -0400
In-Reply-To: <20171031182835.9834-1-bjb@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Brenda J. Butler" <bjb@mojatatu.com>
Date: Tue, 31 Oct 2017 14:28:35 -0400

> Check if tcase[k] is an instance of a list (is or is derived from list)
> instead of checking if it is a list.
> 
> This will be useful if the data structures change to be something
> that implements list, instead of being an actual list.  In that
> case, this code will not have to change.
> 
> Signed-off-by: Brenda J. Butler <bjb@mojatatu.com>

Applied.
