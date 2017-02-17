From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [PATCH net-next] bridge: don't indicate expiry on
 NTF_EXT_LEARNED fdb entries
Date: Fri, 17 Feb 2017 11:30:23 +0200
Message-ID: <20170217093023.GA18742@splinter>
References: <1487281084-11769-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        nikolay@cumulusnetworks.com, jiri@resnulli.us, idosch@mellanox.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:52873 "EHLO
        out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932741AbdBQJa1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 04:30:27 -0500
Content-Disposition: inline
In-Reply-To: <1487281084-11769-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 16, 2017 at 01:38:04PM -0800, Roopa Prabhu wrote:
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

Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Tested-by: Ido Schimmel <idosch@mellanox.com>

Thanks!
