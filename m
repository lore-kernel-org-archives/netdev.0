From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: bug fix when loading after SAN boot
Date: Fri, 04 May 2012 11:57:53 -0400 (EDT)
Message-ID: <20120504.115753.1701261151183409987.davem@davemloft.net>
References: <1336033320-16440-1-git-send-email-ariele@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: ariele@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54731 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751182Ab2EDP6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 11:58:00 -0400
In-Reply-To: <1336033320-16440-1-git-send-email-ariele@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ariel Elior" <ariele@broadcom.com>
Date: Thu, 3 May 2012 11:22:00 +0300

> +	/* clear hw from errors which mnay have resulted from an interrupted
> +	 * dmae transaction.
> +	 */

Please fix the typos in this comment.
