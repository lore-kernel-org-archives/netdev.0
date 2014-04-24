From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 1/4] bonding: Changed hashing function to just
 provide hash
Date: Thu, 24 Apr 2014 13:04:59 -0400 (EDT)
Message-ID: <20140424.130459.701047382881427176.davem@davemloft.net>
References: <1398209415-3727-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, vfalico@redhat.com, andy@greyhouse.net,
	netdev@vger.kernel.org, edumazet@google.com, maze@google.com
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60896 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753419AbaDXRFC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 13:05:02 -0400
In-Reply-To: <1398209415-3727-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>
Date: Tue, 22 Apr 2014 16:30:15 -0700

> Modified the hash function to return just hash separating from the
> modulo operation that can be performed by the caller. This is to
> make way for the tlb mode to use the same hashing policies that
> are used in the 802.3ad and Xor mode.
> 
> Change-Id: I276609e87e0ca213c4d1b17b79c5e0b0f3d0dd6f
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

Applied.
