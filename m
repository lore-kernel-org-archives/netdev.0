From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rtnetlink: Add dump all for netconf
Date: Wed, 22 Mar 2017 12:45:42 -0700 (PDT)
Message-ID: <20170322.124542.1014543395361443102.davem@davemloft.net>
References: <1490124146-7021-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43780 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759013AbdCVTpo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 15:45:44 -0400
In-Reply-To: <1490124146-7021-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue, 21 Mar 2017 12:22:26 -0700

> Use the rtnl_dump_all to dump all netconf handlers that have been
> registered. Allows userspace to send a dump request for PF_UNSPEC
> and get all families.
> 
> Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied, thanks David.
