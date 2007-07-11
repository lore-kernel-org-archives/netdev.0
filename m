From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [PATCH resend] rewrite AF_UNIX garbage collector, fixes race
Date: Wed, 11 Jul 2007 09:04:10 +0200
Message-ID: <E1I8WF8-0007we-00@dorka.pomaz.szeredi.hu>
References: <20070710.221224.48800386.davem@davemloft.net>
	<20070710222511.bcc87825.akpm@linux-foundation.org>
	<E1I8VtC-0007uM-00@dorka.pomaz.szeredi.hu> <20070710.235142.92583640.davem@davemloft.net>
Cc: miklos@szeredi.hu, akpm@linux-foundation.org,
	netdev@vger.kernel.org, ebiederm@xmission.com,
	viro@ftp.linux.org.uk, alan@lxorguk.ukuu.org.uk,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2.sa.eol.hu ([212.108.200.109]:53813 "EHLO
	mail-gw2.sa.eol.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751054AbXGKHEg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 03:04:36 -0400
In-reply-to: <20070710.235142.92583640.davem@davemloft.net> (message from
	David Miller on Tue, 10 Jul 2007 23:51:42 -0700 (PDT))
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > This may seem low priority and irrelevant, but it _is_ a bug, and it's
> > affecting a real world application.  So please take that into
> > consideration.
> 
> I'm not the only person who hasn't reviewed your latest patch yet.
> 
> You may want to consider that this might have something to do with
> your attitude and behavior, rather than the importance of your patch.

I think it's more to do with everyone being busy, and not considering
this important, which is understandable, this is a fringe
functionality, and almost nobody uses it.

Problems with my attitude probably stem from this fact.  This bug is
important to _me_, and I behave accordingly, ant that seems
inappropriate.

Dave, I really appreciate the work you do.  Please forgive my
impatience.

Miklos
