From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT]: Networking
Date: Mon, 6 Apr 2009 18:25:31 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0904061824410.4010@localhost.localdomain>
References: <20090406.175752.236260059.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:41920 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751621AbZDGB1Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2009 21:27:24 -0400
In-Reply-To: <20090406.175752.236260059.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



The sky2 driver is buggered (by the previous pull, I presume). Some PCI 
interaction. NULL pointer dereference at boot.

		Linus
