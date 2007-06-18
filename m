From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [PATCH] fix race in AF_UNIX
Date: Mon, 18 Jun 2007 13:06:39 +0200
Message-ID: <E1I0F4B-0007PM-00@dorka.pomaz.szeredi.hu>
References: <E1I0ElR-0007Kz-00@dorka.pomaz.szeredi.hu>
	<20070618.035144.64026005.davem@davemloft.net>
	<E1I0EtI-0007Ma-00@dorka.pomaz.szeredi.hu> <20070618.040253.129088293.davem@davemloft.net>
Cc: tgraf@suug.ch, akpm@linux-foundation.org, viro@ftp.linux.org.uk,
	alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1.sa.eol.hu ([212.108.200.67]:38704 "EHLO
	mail-gw1.sa.eol.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752551AbXFRLHW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 07:07:22 -0400
In-reply-to: <20070618.040253.129088293.davem@davemloft.net> (message from
	David Miller on Mon, 18 Jun 2007 04:02:53 -0700 (PDT))
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > I'm all for fixing this gc mess that we have now.  But please don't
> > expect me to be the one who's doing it.
> 
> Don't worry, I only expect you to make the situation worse :-)

That's real nice.  Looks like finding and fixing bugs in not
appreciated in the networking subsystem :-/

Miklos
