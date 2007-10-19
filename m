From: maximilian attems <max@stro.at>
Subject: Re: iproute2: git pull request from debian repo.
Date: Fri, 19 Oct 2007 15:06:16 +0200
Message-ID: <20071019130616.GH1362@baikonur.stro.at>
References: <20071019122753.GA30078@scream.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from baikonur.stro.at ([213.239.196.228]:56188 "EHLO
	baikonur.stro.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753833AbXJSNGg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 09:06:36 -0400
Content-Disposition: inline
In-Reply-To: <20071019122753.GA30078@scream.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 19, 2007 at 02:27:53PM +0200, Andreas Henriksson wrote:
> Hello!
> 
> We now have our brand new git repo set up for the debian package. We have
> created a branch called "patches" where we are going to put stuff that we
> hope will get merged upstream.
> 
> I'm sending out this pull request to get confirmation about if we are on the
> right track ...
> 
> The repo url is git://git.debian.org/git/collab-maint/pkg-iproute.git
> and the branch you're supposed to look at is "patches", as I mentioned.

on klibc i'm asked to attach git log -p on a pull request so
that the patches can be reviewed, please do so too.
 
also apprecitated would be the output of
git log master..patches | git shortlog

> It currently only contains two fixes:
> - trivial syntax fix in the ss(8) manpage, by Justin Pryzby.
>   (Should be a no-brainer.)
> - ip addr flush loop fix (from ubuntu), by Daniel Silverstone
>   (Equivalent to the treatment "ip neigh flush" previously got.
>    This obsoletes the patch from Alexander Wirt which was dropped
>    from the last patch submission.)
> 

happy weekend

-- 
maks
