From: David Miller <davem@davemloft.net>
Subject: Re: silence some noisy printks in irda
Date: Thu, 04 Oct 2012 15:54:56 -0400 (EDT)
Message-ID: <20121004.155456.1370397856748653068.davem@davemloft.net>
References: <20121004133613.GA2913@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45417 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757385Ab2JDTy5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 15:54:57 -0400
In-Reply-To: <20121004133613.GA2913@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Thu, 4 Oct 2012 09:36:13 -0400

> Fuzzing causes these printks to spew constantly.
> Changing them to DEBUG statements is consistent with other usage in the file,
> and makes them disappear when CONFIG_IRDA_DEBUG is disabled.
> 
> Signed-off-by: Dave Jones <davej@redhat.com>

Applied.
