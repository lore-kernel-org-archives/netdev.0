From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 08/10] tty_io: export tty_class
Date: Tue, 2 Jun 2009 15:35:08 +0100
Message-ID: <20090602153508.45e57292@lxorguk.ukuu.org.uk>
References: <1243868091-5315-3-git-send-email-dbaryshkov@gmail.com>
	<1243868091-5315-4-git-send-email-dbaryshkov@gmail.com>
	<1243868091-5315-5-git-send-email-dbaryshkov@gmail.com>
	<1243868091-5315-6-git-send-email-dbaryshkov@gmail.com>
	<1243868091-5315-7-git-send-email-dbaryshkov@gmail.com>
	<1243868091-5315-8-git-send-email-dbaryshkov@gmail.com>
	<1243868091-5315-9-git-send-email-dbaryshkov@gmail.com>
	<20090601160721.7b262469@lxorguk.ukuu.org.uk>
	<bc64b4640906010810l8ace77byfbd650b549f9b5c3@mail.gmail.com>
	<20090601163418.465be751@lxorguk.ukuu.org.uk>
	<20090602142241.GA18656@doriath.ww600.siemens.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, slapin@ossfans.org,
	maxim.osipov@siemens.com, dmitry.baryshkov@siemens.com,
	oliver.fendt@siemens.com
To: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:35233 "EHLO
	www.etchedpixels.co.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752499AbZFBOeC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 10:34:02 -0400
In-Reply-To: <20090602142241.GA18656@doriath.ww600.siemens.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Yes - create a proper tty helper function for doing the job and document
> > what it does. That way if the tty layer is changed it is obvious that
> > this code also needs considering.
> 
> Is this suitable:

Perfect - add the needed documentation to the public function and submit
it for merging.

Alan
