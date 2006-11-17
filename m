From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [BUG] CREDITS or CREDITS-YOURSELVES
Date: Thu, 16 Nov 2006 23:25:01 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0611162324080.3349@woody.osdl.org>
References: <20061117072518.GA1616@ff.dom.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:39836 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1755535AbWKQHZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Nov 2006 02:25:07 -0500
To: Jarek Poplawski <jarkao2@o2.pl>
In-Reply-To: <20061117072518.GA1616@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 17 Nov 2006, Jarek Poplawski wrote:
> 
> With great astonishment I've found none of
> these "networking" names in the CREDITS file:
> Stephen Hemminger, Thomas Graf, Alexey Kuznetsov,
> Andrew Morton, Pedro Roque, Jamal Hadi Salim,
> Herbert Xu etc.

You should basically consider the CREDITS file to be legacy stuff from 
five+ years ago.

For the last five years or so, you can find the real credits in the source 
control history. That didn't use to be true.

		Linus
