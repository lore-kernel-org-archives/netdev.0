From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] stmmac: remove two useless initialisation
Date: Wed, 23 May 2012 02:42:11 -0400 (EDT)
Message-ID: <20120523.024211.816676351593259308.davem@davemloft.net>
References: <1337754964-21754-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55322 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751758Ab2EWGmQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2012 02:42:16 -0400
In-Reply-To: <1337754964-21754-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


You really need to post your patches properly.

In particular, you need to indicate, either in an initial "[PATCH 0/N]"
posting, or in the subject lines of that patch, exactly what tree
you are targetting.

And if this is meant for net-next, I told you specifically that net-next
is not open right now and you need to submit this later when I make
the announcement here that it is open.

We are in the middle of the merge window, and therefore you should only
be submitting bug fixes against the 'net' tree.

It is extremely irritating that, when I go out of my way to make
announcements here on this list, multiple times, about what kind of
patches are appropriate and what kinds are not, and yet people still
do not listen and they still submit any old crap they feel like
submitting.

People need to stop this, now.

Pay attention to the development state, and follow the rules,
otherwise you'll royally piss me off and I'll ignore your patches
completely.

Thanks.
