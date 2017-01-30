From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] lwtunnel: remove device arg to
 lwtunnel_build_state
Date: Mon, 30 Jan 2017 15:14:59 -0500 (EST)
Message-ID: <20170130.151459.1514059390257376169.davem@davemloft.net>
References: <1485806857-3651-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37828 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751033AbdA3UQj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 15:16:39 -0500
In-Reply-To: <1485806857-3651-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Mon, 30 Jan 2017 12:07:37 -0800

> Nothing about lwt state requires a device reference, so remove the
> input argument.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> v2
> - rebased to top of net-next tree

Looks fine, applied, thanks David.
