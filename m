From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 00/18] mlxsw: Improve extensibility
Date: Fri, 26 May 2017 15:21:39 -0400 (EDT)
Message-ID: <20170526.152139.1067635701572902907.davem@davemloft.net>
References: <20170526063740.8909-1-jiri@resnulli.us>
        <20170526.152035.708896761272676930.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, mlxsw@mellanox.com,
        stephen@networkplumber.org, nikolay@cumulusnetworks.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43786 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753297AbdEZTVl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 15:21:41 -0400
In-Reply-To: <20170526.152035.708896761272676930.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 26 May 2017 15:20:35 -0400 (EDT)

> Nice cleanups and consolidation, but like Nikolay I'm not so sure
> about all the exports.
> 
> It might even be cleaner (believe it or not) to have the bridge
> structure (or at least a subset of it) be something public that
> drivers can query using inline helpers.

Just to be clear I did apply this series, and the above is about
future considerations.

Thanks.
