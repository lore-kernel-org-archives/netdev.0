From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [PATCH] fix race in AF_UNIX
Date: Mon, 18 Jun 2007 13:46:05 +0200
Message-ID: <E1I0FgL-0007VY-00@dorka.pomaz.szeredi.hu>
References: <20070618.035144.64026005.davem@davemloft.net>
	<E1I0EtI-0007Ma-00@dorka.pomaz.szeredi.hu>
	<20070618.040253.129088293.davem@davemloft.net> <20070618.040915.35042963.davem@davemloft.net>
Cc: tgraf@suug.ch, akpm@linux-foundation.org, viro@ftp.linux.org.uk,
	alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3.sa.ew.hu ([212.108.200.82]:58690 "EHLO
	mail-gw3.sa.ew.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761148AbXFRLqu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 07:46:50 -0400
In-reply-to: <20070618.040915.35042963.davem@davemloft.net> (message from
	David Miller on Mon, 18 Jun 2007 04:09:15 -0700 (PDT))
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > > I'm all for fixing this gc mess that we have now.  But please don't
> > > expect me to be the one who's doing it.
> > 
> > Don't worry, I only expect you to make the situation worse :-)
> 
> In any event, I'll try to find some time to look more at your patch.
> 
> But just like you don't want to be expected to rewrite the AF_UNIX GC
> code, you can't expect me to go right to your patch right when you
> want me to.
> 
> I am one human being, and I depend upon other developers to help me
> out with patch review and so on.  If nobody else wants to review your
> patch that doesn't work out so well for me.

Sure, no problem.  I just pinged you after a week of inactivity, to
make sure it hasn't been forgotten.  Just say if you are busy and I'll
wait, but trying to forget the issue is not the way to deal with it.

> Your behavior also tends to make me (and others) put your patch near
> the end of the todo list rather than near the top.  Fix your attitude
> and people will enjoy reviewing your patches that much more.  Reviewing
> your work will become something to look forward to rather than a chore.

I'll happily admit I'm a fool when it comes to social interactions.

Miklos
