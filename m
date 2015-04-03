From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] ipv4: coding style - comparisons with NULL
Date: Fri, 03 Apr 2015 12:11:38 -0400 (EDT)
Message-ID: <20150403.121138.1140806036726597601.davem@davemloft.net>
References: <1428049047-14783-1-git-send-email-ipm@chirality.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ipm@chirality.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48626 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751491AbbDCQLn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 12:11:43 -0400
In-Reply-To: <1428049047-14783-1-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Morris <ipm@chirality.org.uk>
Date: Fri,  3 Apr 2015 09:17:25 +0100

> Per the suggestion of Joe Perches, attached is a patch which aligns the
> coding style in ipv4 for comparisons with NULL.
> 
> The code uses multiple different styles when comparing with NULL (I.e. 
> x == NULL and !x as well as x != NULL and x). Generally the latter form
> is preferred in netdev and so this changes aligns the code to this style.

Series applied, thanks.
