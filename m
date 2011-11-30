From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] route: set iif and oif information in flowi struct
Date: Tue, 29 Nov 2011 19:01:45 -0500 (EST)
Message-ID: <20111129.190145.548852258294275388.davem@davemloft.net>
References: <1322511292-1413-1-git-send-email-ulrich.weber@sophos.com>
	<1322511292-1413-3-git-send-email-ulrich.weber@sophos.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ulrich.weber@Sophos.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44761 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757045Ab1K3ABt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 19:01:49 -0500
In-Reply-To: <1322511292-1413-3-git-send-email-ulrich.weber@sophos.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ulrich Weber <ulrich.weber@Sophos.com>
Date: Mon, 28 Nov 2011 21:14:51 +0100

> +	}
> +	else {
 ...
> +	}
> +	else {

Besides Julian's comments, these are not properly formatted, use:

	} else {

instead.
