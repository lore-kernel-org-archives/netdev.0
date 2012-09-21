From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: remove false warning regarding interrupt
 number
Date: Fri, 21 Sep 2012 13:27:41 -0400 (EDT)
Message-ID: <20120921.132741.2134378410644822329.davem@davemloft.net>
References: <1348154801-6592-1-git-send-email-ariele@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: ariele@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50600 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932078Ab2IUR1n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 13:27:43 -0400
In-Reply-To: <1348154801-6592-1-git-send-email-ariele@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ariel Elior" <ariele@broadcom.com>
Date: Thu, 20 Sep 2012 18:26:41 +0300

> Since version 7.4 the FW configures in the pci config space the max
> number of interrupts available to the physical function, instead of
> the exact number to use.
> This causes a false warning in driver when comparing the number of
> configured interrupts to the number about to be used.
> 
> Signed-off-by: Ariel Elior <ariele@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied, thanks.
