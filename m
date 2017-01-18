From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] lwtunnel: remove device arg to
 lwtunnel_build_state
Date: Wed, 18 Jan 2017 17:08:11 -0500 (EST)
Message-ID: <20170118.170811.1056824294403065430.davem@davemloft.net>
References: <1484694521-17479-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42202 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753192AbdARWIq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 17:08:46 -0500
In-Reply-To: <1484694521-17479-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue, 17 Jan 2017 15:08:41 -0800

> Nothing about lwt state requires a device reference, so remove the
> input argument.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

This is going to conflict with the module loading patch, why don't you
respin this the next time I merge net into net-next?

Thanks.
