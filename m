From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] checkpatch/SubmittingPatches: Suggest line wrapping
 commit messages at 72 columns
Date: Wed, 01 Apr 2015 12:28:46 -0700
Message-ID: <1427916526.31790.69.camel@perches.com>
References: <1427634005-4313-1-git-send-email-ipm@chirality.org.uk>
	 <20150331.135338.519327316482059081.davem@davemloft.net>
	 <1427825806.10376.42.camel@perches.com>
	 <1427827225.18175.3.camel@perches.com>
	 <20150401122001.f0203b0ddac348db14e5822a@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jonathan Corbet <corbet@lwn.net>,
	David Miller <davem@davemloft.net>,
	Ian Morris <ipm@chirality.org.uk>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	linux-doc <linux-doc@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20150401122001.f0203b0ddac348db14e5822a@linux-foundation.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-04-01 at 12:20 -0700, Andrew Morton wrote:
> On Tue, 31 Mar 2015 11:40:25 -0700 Joe Perches <joe@perches.com> wrote:
> 
> > Commit messages are sometimes overly long.
> > Suggest line wrapping at 72 columns.
> 
> waah, I use 75 and this patch has ruined my life.

hmm... 1/4/15 or is it 4/1/15?

> Is there some way I can disable just this check without patching
> checkpatch?  I suspect a lot of people will be interested in doing
> this ;)

You could s/72/75/.  I won't care.

Using "./scripts/checkpatch.pl --ignore=commit_log_long_line"
would work too.



