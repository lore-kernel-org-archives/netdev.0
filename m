From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH 2/2] usbnet & cdc-ether: Autosuspend for online devices
Date: Fri, 4 Dec 2009 09:14:18 +0100
Message-ID: <200912040914.19339.oliver@neukum.org>
References: <200912032241.43772.oliver@neukum.org> <20091203.134532.225926933.davem@davemloft.net> <20091203.152721.266674825.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:40272 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753115AbZLDIOJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2009 03:14:09 -0500
In-Reply-To: <20091203.152721.266674825.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Freitag, 4. Dezember 2009 00:27:21 schrieb David Miller:
> From: David Miller <davem@davemloft.net>
> Date: Thu, 03 Dec 2009 13:45:32 -0800 (PST)
> 
> > But this all might be due to some other changes I applied today and
> > didn't push out yet to net-next-2.6, let me check on that for you.
> 
> I've resolved this, it was a conflict with Joe Perches's drivers/net
> coding style cleanups that went in today.

OK, so you don't need me to respin on a newer tree?
I was doubting my own sanity.

	Regards
		Oliver
