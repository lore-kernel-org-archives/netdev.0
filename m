From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix race in AF_UNIX
Date: Mon, 18 Jun 2007 00:57:11 -0700 (PDT)
Message-ID: <20070618.005711.21897961.davem@davemloft.net>
References: <20070607.184731.10907840.davem@davemloft.net>
	<E1HxgeN-0006Io-00@dorka.pomaz.szeredi.hu>
	<E1I0BzQ-0006gZ-00@dorka.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: viro@ftp.linux.org.uk, alan@lxorguk.ukuu.org.uk,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: miklos@szeredi.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49303
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752572AbXFRH4x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 03:56:53 -0400
In-Reply-To: <E1I0BzQ-0006gZ-00@dorka.pomaz.szeredi.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 18 Jun 2007 09:49:32 +0200

> Ping Dave,
> 
> Since there doesn't seem to be any new ideas forthcoming, can we
> please decide on either one of my two sumbitted patches?

You just need to be patient, we can't just put a bad patch
in because a better one has not been suggested yet :-)
