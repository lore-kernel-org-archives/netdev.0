From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: mac80211 2014-12-18
Date: Thu, 18 Dec 2014 15:35:20 -0500 (EST)
Message-ID: <20141218.153520.221364366280641527.davem@davemloft.net>
References: <1418911822.6134.13.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48593 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125AbaLRUfW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2014 15:35:22 -0500
In-Reply-To: <1418911822.6134.13.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Thu, 18 Dec 2014 15:10:22 +0100

> Also from me a first pull request - we have a number of really old
> issues that happened to crop up now with new work (or just more testing)
> in the right areas as well as some small bugs newly introduced in 3.19.
> 
> Let me know if there are any problems.

Pulled, but:

1) Don't put things into a merge commit, I take the text from your
   pull request email and that becomes the merge commit contents.
   Put it in your pull request email.

2) I want every pull request I get at least CC:'d to netdev.

> The following changes since commit 5fbea33740aeb948422d7b7e8aafbeac362264b2:
> 
>   r8169:update rtl8168g pcie ephy parameter (2014-12-11 21:38:52 -0500)
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git tags/mac80211-for-davem-2014-12-18
> 
> for you to fetch changes up to 28a9bc68124c319b2b3dc861e80828a8865fd1ba:
> 
>   mac80211: free management frame keys when removing station (2014-12-17 14:00:17 +0100)
