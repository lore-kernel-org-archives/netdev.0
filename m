From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] checkpatch/SubmittingPatches: Suggest line wrapping
 commit messages at 72 columns
Date: Wed, 1 Apr 2015 13:18:24 -0700
Message-ID: <20150401131824.efafdf9c97188f97cb4a212c@linux-foundation.org>
References: <1427634005-4313-1-git-send-email-ipm@chirality.org.uk>
	<20150331.135338.519327316482059081.davem@davemloft.net>
	<1427825806.10376.42.camel@perches.com>
	<1427827225.18175.3.camel@perches.com>
	<20150401122001.f0203b0ddac348db14e5822a@linux-foundation.org>
	<20150401213618.029f8c1f@lwn.net>
	<1427918969.31790.78.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jonathan Corbet <corbet@lwn.net>,
	David Miller <davem@davemloft.net>,
	Ian Morris <ipm@chirality.org.uk>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	linux-doc <linux-doc@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1427918969.31790.78.camel@perches.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 01 Apr 2015 13:09:29 -0700 Joe Perches <joe@perches.com> wrote:

> On Wed, 2015-04-01 at 21:36 +0200, Jonathan Corbet wrote:
> > On Wed, 1 Apr 2015 12:20:01 -0700
> > Andrew Morton <akpm@linux-foundation.org> wrote:
> > > waah, I use 75 and this patch has ruined my life.
> 
> crybaby... :)

I'm very sensitive.

> > I use 75 too, FWIW.
> > 
> > It seems to me that nobody out there complains about 75-character lines
> > in commit logs; it's the 120-character lines that irritate people.  I
> > would suggest that this limit could be set to 75 (or even, say, 77)
> 
> 77 might be one too many.
> 
> git log has a default 4 space indent of the commit message so
> 75 or 76 would still fit an 80 column screen.

That's a good point.  Good enough to be in a changelog ;)

76 sounds a bit risky - I don't think I trust every output device to
dtrt with 80-column text.  I might be wrong about that.  75 would save
my handkerchiefs.
