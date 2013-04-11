From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 1/2] bonding: fix netdev event NULL pointer
 dereference
Date: Thu, 11 Apr 2013 13:28:49 -0400 (EDT)
Message-ID: <20130411.132849.1638096873086760888.davem@davemloft.net>
References: <1365538644-1502-1-git-send-email-nikolay@redhat.com>
	<1365687905-1053-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, fubar@us.ibm.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36813 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934932Ab3DKR2w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 13:28:52 -0400
In-Reply-To: <1365687905-1053-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When you repost a patch that's part of a series, you must resubmit all
patches in that series, not just the one that changed.

You should also provide a header posting "[PATCH 0/N] ..." that explains
the high level purpose and intent of the patch set.
