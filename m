From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv6: fix incorrect type in declaration
Date: Thu, 12 Dec 2013 16:14:32 -0500 (EST)
Message-ID: <20131212.161432.777791666238406204.davem@davemloft.net>
References: <1386864478-3879-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sergei.shtylyov@cogentembedded.com
To: florent.fourcot@enst-bretagne.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39812 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751602Ab3LLVOe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 16:14:34 -0500
In-Reply-To: <1386864478-3879-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Date: Thu, 12 Dec 2013 17:07:58 +0100

> Introduced by 1397ed35f22d7c30d0b89ba74b6b7829220dfcfd
>   "ipv6: add flowinfo for tcp6 pkt_options for all cases"
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> 
> V2: fix the title, add empty line after the declaration (Sergei Shtylyov
> feedbacks)

Applied, thanks.
