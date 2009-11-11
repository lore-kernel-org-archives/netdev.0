From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH resent] Documentation: rw_lock lessons learned
Date: Wed, 11 Nov 2009 09:37:24 -0800
Message-ID: <20091111093724.4f40a48d@nehalam>
References: <4AF9C540.5090403@gmail.com>
	<20091110180646.2e5859a8@nehalam>
	<4AFAEF78.4080807@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758396AbZKKRhl@vger.kernel.org>
In-Reply-To: <4AFAEF78.4080807@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 11 Nov 2009 12:08:08 -0500
William Allen Simpson <william.allen.simpson@gmail.com> wrote:

> Stephen Hemminger wrote:
> > I would rather see the text in Documentation/spinlocks give an explaination
> > as to why reader/writer locks are normally not desirable. 
> > 
> > The whole document needs work to make it a developer document, rather than
> > a historical mail thread..  A good document says what should be done today,
> > and does not have old junk or ask the reader to overly new context
> > on old information.
> > 
> You wish me to merge our patches?

Sure, I am more concerned about document structure being readable than
preserving my sloppy prose.


> Or this is a second patch in a proposed series?

No. But taking more input from others (maybe Randy will help he is a good
editor) would get this back in shape.

-- 
