From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [patch]reset_resume for cdc-ether
Date: Thu, 3 Dec 2009 11:26:03 +0100
Message-ID: <200912031126.03058.oliver@neukum.org>
References: <20091202.221627.133392199.davem@davemloft.net> <200912031056.17103.oliver@neukum.org> <20091203.021456.40580217.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: david-b@pacbell.net, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:36350 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341AbZLCK0A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 05:26:00 -0500
In-Reply-To: <20091203.021456.40580217.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Donnerstag, 3. Dezember 2009 11:14:56 schrieb David Miller:
> From: Oliver Neukum <oliver@neukum.org>
> Date: Thu, 3 Dec 2009 10:56:17 +0100
> 
> > Am Donnerstag, 3. Dezember 2009 07:22:54 schrieb David Miller:
> >> > I'm going to apply this patch and the USB autosuspend one too.
> >>
> >> Actually, neither patch applies to net-next-2.6
> >>
> >> Oliver can you respin your changes and add a proper signoff
> >> to the autosuspend patch?
> >
> > Hi,
> >
> > here's autosuspend again.
> 
> It doesn't apply to my tree still:
> 
> davem@sunset:~/src/GIT/net-next-2.6$ git apply --check
>  --whitespace=error-all diff error: patch failed:
>  drivers/net/usb/cdc_ether.c:411
> error: drivers/net/usb/cdc_ether.c: patch does not apply
> davem@sunset:~/src/GIT/net-next-2.6$

Am I making patches against the wrong tree?
Can you tell me exactly which tree I need to clone?

	Regards
		Oliver
