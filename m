From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] checkpatch/SubmittingPatches: Suggest line wrapping
 commit messages at 72 columns
Date: Wed, 1 Apr 2015 12:20:01 -0700
Message-ID: <20150401122001.f0203b0ddac348db14e5822a@linux-foundation.org>
References: <1427634005-4313-1-git-send-email-ipm@chirality.org.uk>
	<20150331.135338.519327316482059081.davem@davemloft.net>
	<1427825806.10376.42.camel@perches.com>
	<1427827225.18175.3.camel@perches.com>
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
In-Reply-To: <1427827225.18175.3.camel@perches.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 31 Mar 2015 11:40:25 -0700 Joe Perches <joe@perches.com> wrote:

> Commit messages are sometimes overly long.
> Suggest line wrapping at 72 columns.

waah, I use 75 and this patch has ruined my life.

Is there some way I can disable just this check without patching
checkpatch?  I suspect a lot of people will be interested in doing
this ;)
