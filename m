From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: Correct default Tx switching behaviour
Date: Tue, 14 Jan 2014 17:11:38 -0800 (PST)
Message-ID: <20140114.171138.493963682006095335.davem@davemloft.net>
References: <1389530279-14963-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ariele@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54131 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751423AbaAOBLj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 20:11:39 -0500
In-Reply-To: <1389530279-14963-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <yuvalmin@broadcom.com>
Date: Sun, 12 Jan 2014 14:37:59 +0200

> With this patch bnx2x will configure the PF to perform Tx switching on
> out-going traffic as soon as SR-IOV is dynamically enabled and de-activate
> it when it is disabled.
> This will allow VFs to communicate with their parent PFs.
> 
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Ariel Elior <ariele@broadcom.com>

Applied.
