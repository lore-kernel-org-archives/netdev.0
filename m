From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: remove vni zero check and drop for
 COLLECT_METADATA
Date: Sat, 11 Feb 2017 21:26:14 -0500 (EST)
Message-ID: <20170211.212614.1589003625673836126.davem@davemloft.net>
References: <1486791516-10285-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@ovn.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44510 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751114AbdBLC0Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Feb 2017 21:26:16 -0500
In-Reply-To: <1486791516-10285-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Fri, 10 Feb 2017 21:38:36 -0800

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This patch drops the vni zero check for COLLECT_METADATA mode.
> It is not really needed, vni zero is a valid vni.
> 
> Fixes: 3ad7a4b141eb ("vxlan: support fdb and learning in COLLECT_METADATA mode"
> Reported-by: Joe Stringer <joe@ovn.org>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Applied.
