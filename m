From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ipmr: Remove nowait arg to ipmr_get_route
Date: Sun, 08 Jan 2017 17:14:53 -0500 (EST)
Message-ID: <20170108.171453.2109967923875032995.davem@davemloft.net>
References: <1483753146-16168-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42874 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753847AbdAHWOz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2017 17:14:55 -0500
In-Reply-To: <1483753146-16168-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Fri,  6 Jan 2017 17:39:06 -0800

> ipmr_get_route has 1 caller and the nowait arg is 0. Remove the arg and
> simplify ipmr_get_route accordingly.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied.
