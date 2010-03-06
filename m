From: Joe Perches <joe@perches.com>
Subject: Re: [RESEND PATCH 0/2] Make functions of dev_<level> macros,
 recursive vsnprintf
Date: Sat, 06 Mar 2010 15:57:21 -0800
Message-ID: <1267919841.1937.2.camel@Joe-Laptop.home>
References: <cover.1267682641.git.joe@perches.com>
	 <20100304143837.af39845d.akpm@linux-foundation.org>
	 <alpine.LFD.2.00.1003041504080.3751@localhost.localdomain>
	 <1267911399.849.39.camel@Joe-Laptop.home>
	 <alpine.LFD.2.00.1003061356420.31447@localhost.localdomain>
	 <1267914654.849.81.camel@Joe-Laptop.home>
	 <alpine.LFD.2.00.1003061445490.31447@localhost.localdomain>
	 <alpine.LFD.2.00.1003061455590.31447@localhost.localdomain>
	 <1267918554.849.89.camel@Joe-Laptop.home>
	 <alpine.LFD.2.00.1003061540470.23804@localhost.localdomain>
	 <alpine.LFD.2.00.1003061547490.23804@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Nick Andrew <nick@nick-andrew.net>,
	linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@suse.de>,
	netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1003061547490.23804@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2010-03-06 at 15:48 -0800, Linus Torvalds wrote:
> On Sat, 6 Mar 2010, Linus Torvalds wrote:
> > width: 5 (make it 6 bits and signed)
> > precision: 5 (make it 6 bits, and signed)
> Oh, actually, no, we do that whole left-justification with the flags, we 
> don't need that signed stuff. We do need one special value for the "no 
> width, no precision", though.

What I posted is pretty simple.
I think the added complexity isn't worth it.

If you or anyone else does, all yours.
