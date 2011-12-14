From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: Latency guarantees in HFSC rt service curves
Date: Wed, 14 Dec 2011 00:24:51 -0500
Message-ID: <1323840291.8451.174.camel@denise.theartistscloset.com>
References: <1323467512.3159.93.camel@denise.theartistscloset.com>
	 <4EE358A4.7060302@ziu.info>
	 <1323531352.3159.106.camel@denise.theartistscloset.com>
	 <4EE39D88.9010002@ziu.info>
	 <1323542103.3159.148.camel@denise.theartistscloset.com>
	 <4EE7E3E4.6070409@ziu.info>
	 <1323839798.8451.172.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Michal Soltys <soltys@ziu.info>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.194]:65331 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750751Ab1LNFY5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Dec 2011 00:24:57 -0500
In-Reply-To: <1323839798.8451.172.camel@denise.theartistscloset.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-12-14 at 00:16 -0500, John A. Sullivan III wrote:
> <snip>> 
> > > If you have a chance, could you look at the email I sent entitled "An
> > > error in my HFSC sysadmin documentation".  That's the last piece I
> > > need to fall in place before I can share my documentation of this
> > > week's research.  Thanks - John
> > 
> > Yes, will do.
> I'm guessing I slightly violated the rt guarantee precisely because of
> what I described above.
<snip>
Alas, not.  I just reviewed what I sent and it was calculating deadline
time with monolinear service curves so I'm still making an error
somewhere.  Thanks - John
