From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 0/7] Fix, cleanup, optimize gfar_private
 and the Rx path
Date: Thu, 14 Feb 2013 13:32:39 -0500 (EST)
Message-ID: <20130214.133239.332317397308091436.davem@davemloft.net>
References: <1360854007-11094-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58791 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934813Ab3BNScm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 13:32:42 -0500
In-Reply-To: <1360854007-11094-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Thu, 14 Feb 2013 17:00:00 +0200

> These patches went already through a review round with Paul.
> Changes since the initial version of the patches:
> * split the 1st patch into two patches (01 & 02, as suggested by Paul)
> * added the suggested trivial cleanup patch:
>   gianfar: gfar_process_frame returns void
> * provided "long logs" with detailed comments and explanations

Series applied, thanks.
