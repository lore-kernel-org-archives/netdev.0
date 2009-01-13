From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PULL -tip] fixed few make headers_check warnings
Date: Tue, 13 Jan 2009 13:49:21 +0100
Message-ID: <20090113124921.GA30400@elte.hu>
References: <1231836016.3212.41.camel@jaswinder.satnam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	x86 maintainers <x86@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Jaswinder Singh Rajput <jaswinder@infradead.org>,
	Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:60324 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753864AbZAMMtz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2009 07:49:55 -0500
Content-Disposition: inline
In-Reply-To: <1231836016.3212.41.camel@jaswinder.satnam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Jaswinder Singh Rajput <jaswinder@infradead.org> wrote:

> Hello Ingo,
> 
> Please pull these patches. Earlier I also floated these patches so that 
> I can get some feedback.

Sam, Andrew, David, what's your workflow preference for these bits?

While they are oneliners and i could create a separate branch for these 
and pull Jaswinder's tree (and do build coverage to make sure there's no 
surprised on any arch), it's really up to the maintainers of these files 
to decide on the workflow.

I'd lean towards doing this via the individual maintainers and/or -mm, but 
no strong feelings ...

Even if it's done via a separate tree at minimum it needs the acks from 
the affected maintainers.

	Ingo
