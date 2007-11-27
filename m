From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: bonding sysfs output
Date: Tue, 27 Nov 2007 02:14:18 -0800
Message-ID: <20071127021418.8a05d225.akpm@linux-foundation.org>
References: <87tznafjeu.fsf@szonett.ki.iif.hu>
	<20071125205150.4e49915f.akpm@linux-foundation.org>
	<87lk8lflzf.fsf@szonett.ki.iif.hu>
	<20071127004445.a046f791.akpm@linux-foundation.org>
	<87prxwnh9g.fsf@tac.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Ferenc Wagner <wferi@niif.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:59713 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753764AbXK0KPE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 05:15:04 -0500
In-Reply-To: <87prxwnh9g.fsf@tac.ki.iif.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 27 Nov 2007 10:56:43 +0100 Ferenc Wagner <wferi@niif.hu> wrote:

> > - raise patches against the latest Linus tree
> > (ftp://ftp.kernel.org/pub/linux/kernel/v2.6/snapshots/)
> 
> I thought it was better to change to git.  Isn't it so?

Yes, git is a bit more uptodate than the snapshots.  But if that matters
you were very unlucky.

> SubmittingPatches has nothing to say about that...
> Can I find collected best practices somewhere?  Which tree, which
> branch, how/when to rebase, format-patch, etc...

gosh.  Documentation/Submit*,
http://www.zip.com.au/~akpm/linux/patches/stuff/tpp.txt,
http://linux.yyz.us/patch-format.html, other places.  Probably people have
written books about it by now.  But don't sweat it - you're close enough ;)

