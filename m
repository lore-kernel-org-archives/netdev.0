From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix race in AF_UNIX
Date: Mon, 18 Jun 2007 04:02:53 -0700 (PDT)
Message-ID: <20070618.040253.129088293.davem@davemloft.net>
References: <E1I0ElR-0007Kz-00@dorka.pomaz.szeredi.hu>
	<20070618.035144.64026005.davem@davemloft.net>
	<E1I0EtI-0007Ma-00@dorka.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, akpm@linux-foundation.org, viro@ftp.linux.org.uk,
	alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: miklos@szeredi.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50004
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760776AbXFRLCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 07:02:35 -0400
In-Reply-To: <E1I0EtI-0007Ma-00@dorka.pomaz.szeredi.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 18 Jun 2007 12:55:24 +0200

> I'm all for fixing this gc mess that we have now.  But please don't
> expect me to be the one who's doing it.

Don't worry, I only expect you to make the situation worse :-)
