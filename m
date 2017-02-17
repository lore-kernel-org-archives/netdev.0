From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: don't indicate expiry on
 NTF_EXT_LEARNED fdb entries
Date: Fri, 17 Feb 2017 13:57:13 -0500 (EST)
Message-ID: <20170217.135713.669555558575530862.davem@davemloft.net>
References: <1487281084-11769-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com,
        jiri@resnulli.us, idosch@mellanox.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47242 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932673AbdBQS5P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 13:57:15 -0500
In-Reply-To: <1487281084-11769-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Thu, 16 Feb 2017 13:38:04 -0800

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> added_by_external_learn fdb entries are added and expired by
> external entities like switchdev driver or external controllers.
> ageing is already disabled for such entries. Hence, don't
> indicate expiry for such fdb entries.
> 
> CC: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> CC: Jiri Pirko <jiri@resnulli.us>
> CC: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Applied.
