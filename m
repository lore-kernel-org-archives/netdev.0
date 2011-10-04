From: Christoph Lameter <cl@gentwo.org>
Subject: Re: big picture UDP/IP performance question re 2.6.18  -> 2.6.32
Date: Tue, 4 Oct 2011 14:42:28 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1110041442020.15871@router.home>
References: <6.2.5.6.2.20111003112108.03a83a28@binnacle.cx>  <alpine.DEB.2.00.1110041358500.12199@router.home> <1317757118.3580.24.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: starlight@binnacle.cx, Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Willy Tarreau <w@1wt.eu>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp102.prem.mail.ac4.yahoo.com ([76.13.13.41]:20308 "HELO
	smtp102.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S933497Ab1JDTmc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2011 15:42:32 -0400
In-Reply-To: <1317757118.3580.24.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 4 Oct 2011, Joe Perches wrote:

> Idly curious, have you compared bfs performance?

No. BFS has no NUMA support.
