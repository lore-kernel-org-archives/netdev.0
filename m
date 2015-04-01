From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH] checkpatch/SubmittingPatches: Suggest line wrapping
 commit messages at 72 columns
Date: Wed, 1 Apr 2015 21:36:18 +0200
Message-ID: <20150401213618.029f8c1f@lwn.net>
References: <1427634005-4313-1-git-send-email-ipm@chirality.org.uk>
	<20150331.135338.519327316482059081.davem@davemloft.net>
	<1427825806.10376.42.camel@perches.com>
	<1427827225.18175.3.camel@perches.com>
	<20150401122001.f0203b0ddac348db14e5822a@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Cc: Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>,
	Ian Morris <ipm@chirality.org.uk>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	linux-doc <linux-doc@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20150401122001.f0203b0ddac348db14e5822a@linux-foundation.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 1 Apr 2015 12:20:01 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> waah, I use 75 and this patch has ruined my life.
> 
> Is there some way I can disable just this check without patching
> checkpatch?  I suspect a lot of people will be interested in doing
> this ;)

I use 75 too, FWIW.

It seems to me that nobody out there complains about 75-character lines
in commit logs; it's the 120-character lines that irritate people.  I
would suggest that this limit could be set to 75 (or even, say, 77) and
still achieve its real purpose while leaving far fewer ruined lives in its
wake. 

jon
