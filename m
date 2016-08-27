From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 net-next] alx: add tso support
Date: Fri, 26 Aug 2016 21:08:32 -0700 (PDT)
Message-ID: <20160826.210832.1136201505133289447.davem@davemloft.net>
References: <1472148593-5362-1-git-send-email-tobias.regnery@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jcliburn@gmail.com, chris.snook@gmail.com
To: tobias.regnery@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34059 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750798AbcH0EIt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 Aug 2016 00:08:49 -0400
In-Reply-To: <1472148593-5362-1-git-send-email-tobias.regnery@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Regnery <tobias.regnery@gmail.com>
Date: Thu, 25 Aug 2016 20:09:53 +0200

> Add tso/tso6 support to the alx driver.
> Based on information from the downstream driver at github.com/qca/alx
> 
> Signed-off-by: Tobias Regnery <tobias.regnery@gmail.com>
> ---
> Changes in V2:
> 	- don't inline alx_tpd_req

Applied.
