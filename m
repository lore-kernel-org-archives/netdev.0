From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/5] tipc: bug fix and some improvements
Date: Fri, 27 Feb 2015 18:19:08 -0500 (EST)
Message-ID: <20150227.181908.1049884813611678895.davem@davemloft.net>
References: <1425023818-12880-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	jon.maloy@ericsson.com, richard.alpe@ericsson.com,
	ying.xue@windriver.com
To: erik.hugne@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55190 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755536AbbB0XTL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 18:19:11 -0500
In-Reply-To: <1425023818-12880-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <erik.hugne@ericsson.com>
Date: Fri, 27 Feb 2015 08:56:53 +0100

> Most important is a fix for a nullptr exception that would occur when
> name table subscriptions fail. The remaining patches are performance
> improvements and cosmetic changes.
> 
> v2: remove unnecessary whitespace in patch #2 

Series applied, thanks.
