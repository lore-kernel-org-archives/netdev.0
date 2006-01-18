From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: wireless: the contenders
Date: Wed, 18 Jan 2006 15:52:21 -0500
Message-ID: <20060118205221.GA11270@havoc.gtf.org>
References: <20060118200616.GC6583@tuxdriver.com> <43CEA6EB.6080209@pobox.com> <20060118204844.GE6583@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030451AbWARUw1@vger.kernel.org>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jbenc@suse.cz, softmac-dev@sipsolutions.net,
	bcm43xx-dev@lists.berlios.de
Content-Disposition: inline
In-Reply-To: <20060118204844.GE6583@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 18, 2006 at 03:48:49PM -0500, John W. Linville wrote:
> On Wed, Jan 18, 2006 at 03:36:59PM -0500, Jeff Garzik wrote:
> > John W. Linville wrote:
> 
> > >The "master" branch of that tree is (mostly) up-to-date w/ Linus, plus
> > >changes I recently sent to Jeff.  Those changes are also available on
> > >the "upstream-jgarzik" branch, but it is frozen to when I requested
> > >Jeff's pull.
> 
> > Typically I do not update 'master' unless I am also updating 'upstream' 
> > with vanilla Linus changes, in order to avoid screwing up the tree heads 
> > and the diff.  When I do update 'master' from 'upstream', it is a 
> > trivial matter to then pull those changes into 'upstream':
> 
> Good info...thanks!
> 
> FWIW, I have an "origin" branch that corresponds to Linus' tree.
> I think that probably enables the same kind of usage as you noted...?

Yep, it doesn't matter what you call it.

I avoid 'origin' since a 'git pull' without arguments will automatically
update that (and possibly master too).

But it's just a name.  Any branch with vanilla Linus tree in it will
achieve the behavior I described.

	Jeff
