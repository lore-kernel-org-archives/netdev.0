From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: fix handling mf storage modes
Date: Tue, 16 Oct 2012 16:25:09 -0400 (EDT)
Message-ID: <20121016.162509.1880796529664124588.davem@davemloft.net>
References: <1350386907-25737-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ariele@broadcom.com, eilong@broadcom.com
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33359 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752251Ab2JPUZL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2012 16:25:11 -0400
In-Reply-To: <1350386907-25737-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Tue, 16 Oct 2012 13:28:27 +0200

> Since commit a3348722 AFEX FCoE function is continuously reset.
> The patch prevents the resetting and removes debug print
> to stop garbaging syslog.
> 
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Ariel Elior <ariele@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
