From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: Distributed storage release.
Date: Wed, 15 Oct 2008 01:31:23 +0400
Message-ID: <20081014213123.GA32387@2ka.mipt.ru>
References: <20081006160034.GA611@2ka.mipt.ru> <20081012192419.fd8394c9.akpm@linux-foundation.org> <20081013133850.GA13565@2ka.mipt.ru> <20081014155143.GM2009@webber.adilger.int> <20081014161256.GA22286@2ka.mipt.ru> <20081014203529.GW2009@webber.adilger.int> <20081014210827.GA31312@2ka.mipt.ru> <20081014212332.GI15064@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Dilger <adilger@sun.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Matthew Wilcox <matthew@wil.cx>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081014212332.GI15064@parisc-linux.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Matthew.

On Tue, Oct 14, 2008 at 03:23:32PM -0600, Matthew Wilcox (matthew@wil.cx) wrote:
> > Standards are great, but killing a child just because he or she is
> > left-hander, is a bit crazy, don't you think? So it would be quite
> > interesting to hear that (at least one) showstopper for inclusion
> > is a number of spaces :)
> 
> You're blowing this way out of proportion.  Andrew said he'd be happy to
> do a better review of it if you documented it better, but until then all
> he could find time to do was a stylistic review.

Are you absolutely sure we are talking here not about killed christian kids?

Didn't you accidentally miss that part, where I added documentation and
released new version where 10% of the patch is code documentation in
several hours :)

Essentially I resolved all comments Andrew made except checkpatch output
and library functions which I asked if they are really needed. Even
checkpatch output was cleaned (I removed long lines and added comments).

-- 
	Evgeniy Polyakov
