From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT]: Networking for 2.6.30
Date: Thu, 26 Mar 2009 15:56:24 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0903261555290.3032@localhost.localdomain>
References: <20090326.020714.36421849.davem@davemloft.net> <20090326.152515.43533230.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:34891 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751686AbZCZW7V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 18:59:21 -0400
In-Reply-To: <20090326.152515.43533230.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Thu, 26 Mar 2009, David Miller wrote:
> 
> Just FYI, I've just pushed a merge of the changes you pulled in today
> in order to resolve the one merge conflict that arose.

Well, I merged infiniband, and that caused more conflicts. I fixed them 
up, but people need to double-check my fixes.

		Linus
