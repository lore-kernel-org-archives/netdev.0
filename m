From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: pppoe: use correct MTU when using
 Multilink PPP with PPPoE
Date: Fri, 11 Jul 2014 14:14:34 -0700 (PDT)
Message-ID: <20140711.141434.862425773778158308.davem@davemloft.net>
References: <53BF8DC1.1040905@kristov.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-ppp@vger.kernel.org,
	mostrows@gmail.com
To: develop@kristov.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57566 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753146AbaGKVOf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 17:14:35 -0400
In-Reply-To: <53BF8DC1.1040905@kristov.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Bug fixes like these should be targetted at 'net' not 'net-next'.

Please fix your subjects, number your patches, provides a "[PATCH 0/N]"
header posting explaining your changes at a high level, and resubmit
everything.

Thank you.
