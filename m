From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] MAINTAINERS: Orphan usb/net/hso driver
Date: Tue, 28 Feb 2017 10:38:44 -0500 (EST)
Message-ID: <20170228.103844.1220680109576438605.davem@davemloft.net>
References: <30ad43134a6a7d155a257abaa31d120cf2c4d74c.1488271188.git.baruch@tkos.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: baruch@tkos.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46478 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751135AbdB1Psb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 10:48:31 -0500
In-Reply-To: <30ad43134a6a7d155a257abaa31d120cf2c4d74c.1488271188.git.baruch@tkos.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Baruch Siach <baruch@tkos.co.il>
Date: Tue, 28 Feb 2017 10:39:48 +0200

> The email address of Jan Dumon bounces, and there is not relevant information
> in the linked website.
> 
> Signed-off-by: Baruch Siach <baruch@tkos.co.il>

This patch is fine and I will apply it later, however I will make a
general statement that we list USB networking drivers very
inconsistently.

Specifically, some list linux-usb as the mailing list, others list
netdev.  We should figure out which one (or both) is the best to
specify, and apply that rule consitently to the MAINTAINERS file.

Thanks.
