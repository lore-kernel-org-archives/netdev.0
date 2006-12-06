From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH wireless-2.6-git] prism54: WPA/RSN support for fullmac cards
Date: Tue, 5 Dec 2006 20:44:13 -0500
Message-ID: <20061206014407.GB9830@tuxdriver.com>
References: <200610031457.33215.chunkeey@web.de> <200611251750.37313.chunkeey@web.de> <200611260027.33773.dtor@insightbb.com> <200611261147.49231.chunkeey@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Torokhov <dtor@insightbb.com>, netdev@vger.kernel.org,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>, mcgrof@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3636 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759666AbWLFCLj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 21:11:39 -0500
To: chunkeey@web.de
Content-Disposition: inline
In-Reply-To: <200611261147.49231.chunkeey@web.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 26, 2006 at 11:47:49AM +0100, chunkeey@web.de wrote:
> On Sunday, 26. November 2006 06:27, you wrote:
> >
> > Sorry, still need the second "ifup" to bring the card up after plugging
> > it in. ping -f looks good however, I will try to stress it more and will
> > report if I see anything wrong.
> 
> Well, some docs about the chips and firmware would be very handy... 
> has anyone access to conexant's library?

FYI...after latest round of merges, that patch that I've been carrying
in the pending branch of wireless-2.6 no longer applies.

John
-- 
John W. Linville
linville@tuxdriver.com
