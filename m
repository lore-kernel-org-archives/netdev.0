From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] tipc: fix netns refcnt leak
Date: Tue, 17 Mar 2015 22:12:26 -0400 (EDT)
Message-ID: <20150317.221226.129006702114588381.davem@davemloft.net>
References: <1426642379-20503-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, cwang@twopensource.com,
	erik.hugne@ericsson.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55502 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752963AbbCRCM2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 22:12:28 -0400
In-Reply-To: <1426642379-20503-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Wed, 18 Mar 2015 09:32:56 +0800

> The series aims to eliminate the issue of netns refcount leak. But
> during fixing it, another two additional problems are found. So all
> of known issues associated with the netns refcnt leak are resolved
> at the same time in the patchset.

Series applied, thanks.
