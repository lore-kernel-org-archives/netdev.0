From: maximilian attems <maks@sternwelten.at>
Subject: Re: Bug#396185: sky2 freezes in 2.6.17-2-686. Maintainer confirms that it should be fixed in 2.6.19-git tree.
Date: Sat, 18 Nov 2006 12:21:34 +0100
Message-ID: <20061118112134.GI4213@nancy>
References: <20061031073030.6658.11274.reportbug@kano.factory.vocord.ru> <20061031085716.GW13178@baikonur.stro.at> <20061031093051.GA3323@2ka.mipt.ru> <20061031093455.GX13178@baikonur.stro.at> <20061031094424.GA19052@2ka.mipt.ru> <20061116173532.GA10653@2ka.mipt.ru> <20061116093821.318efbe6@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, 396185@bugs.debian.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from baikonur.stro.at ([213.239.196.228]:33297 "EHLO
	baikonur.stro.at") by vger.kernel.org with ESMTP id S1754453AbWKRLVi
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Nov 2006 06:21:38 -0500
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061116093821.318efbe6@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 16 Nov 2006, Stephen Hemminger wrote:

> On Thu, 16 Nov 2006 20:35:32 +0300
> Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> 
> > On Tue, Oct 31, 2006 at 12:44:25PM +0300, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> > > > > > > Bug was filled against 2.6.17-9, but was fixed in recent git (2.6.19-rc3), probably also
> > > > > > > fixed in 2.6.18.1
> > > > > > > 
> > > > > > > Here is link to discussion:
> > > > > > > http://marc.theaimsgroup.com/?l=linux-netdev&m=116227512815783&w=2
> > > > > > > 
> > > > > > 
> > > > > > can you try the linux-image 2.6.18, they are in unstable
> > > > > > and the etch release images.
> > 
> > 2.6.18-1-686 kernel still allows to freeze sky2.
> 
> Fix didn't go in until 2.6.18.2

fix is in the 2.6.18-2-686 linux image, you'd better update
your test box.

thanks
 
-- 
maks
