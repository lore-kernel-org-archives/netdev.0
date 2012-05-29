From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 1/6] net: sh_eth: remove unnecessary function
Date: Tue, 29 May 2012 04:17:11 -0400 (EDT)
Message-ID: <20120529.041711.866739766279184452.davem@davemloft.net>
References: <4FC48570.8040204@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: yoshihiro.shimoda.uh@renesas.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54535 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751943Ab2E2IRR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 May 2012 04:17:17 -0400
In-Reply-To: <4FC48570.8040204@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It is not appropriate to submit cleanups and feature additions for the
'net-next' tree at this time.  That is only valid when I open the
net-next tree back up which will be shortly after the merge window
closes.

If you have bug fixes to submit for the 'net' tree, you must split
them off from these cleanups and submit them seperately.
