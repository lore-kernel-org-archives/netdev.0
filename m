From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] bnx2x: Fix AER semaphore release
Date: Wed, 27 Mar 2013 13:08:49 -0400 (EDT)
Message-ID: <20130327.130849.1946688384476040205.davem@davemloft.net>
References: <1364376483-15050-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com, ariele@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58002 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753048Ab3C0RIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 13:08:51 -0400
In-Reply-To: <1364376483-15050-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Wed, 27 Mar 2013 11:28:03 +0200

> Commit 7fa6f34 "AER revised" erroneously inserted an error-flow
> in which a semaphore is released even though the attempt to take it
> has failed.
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Ariel Elior <ariele@broadcom.com>

Applied.
