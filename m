From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: fix HW initialization using fw 7.8.x
Date: Fri, 02 Nov 2012 21:32:49 -0400 (EDT)
Message-ID: <20121102.213249.2106153755687516533.davem@davemloft.net>
References: <1351497544-13272-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ariele@broadcom.com
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49278 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757342Ab2KCBcu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2012 21:32:50 -0400
In-Reply-To: <1351497544-13272-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Mon, 29 Oct 2012 09:59:04 +0200

> Since commit 96bed4b9 (use FW 7.8.2) BRB HW block needs to be
> initialized using fw values for all devices.
> Otherwise ETS on 57712/578xx will not work.
> 
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Ariel Elior <ariele@broadcom.com>

Applied, thanks.
