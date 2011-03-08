From: Pavel Machek <pavel@ucw.cz>
Subject: Re: ANNOUNCE: debloat-testing kernel git tree
Date: Tue, 8 Mar 2011 07:58:19 +0100
Message-ID: <20110308065819.GA1357@ucw.cz>
References: <20110225222210.GA3618@tuxdriver.com>
 <AANLkTingkcc-dvs_8Nr0vYXdXvuDHEn6sz14tnHzLp8W@mail.gmail.com>
 <87fwr9jxya.fsf@cruithne.co.teklibre.org>
 <AANLkTinpG-xAC-VV-j7EBJB522+BqCyyFd_6N3KEr2Cf@mail.gmail.com>
 <8739n9ii7z.fsf@cruithne.co.teklibre.org>
 <AANLkTi=Cp7N4xqPyU6KWF6DOzFytxaA2BeoXhnhsZ6dp@mail.gmail.com>
 <87tyfph2az.fsf@cruithne.co.teklibre.org>
 <1299176168.2157.14.camel@tardy>
 <4D6FEFD4.9010608@nuim.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rick.jones2@hp.com, Dave T?ht <d@taht.net>, sedat.dilek@gmail.com,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	bloat-devel@lists.bufferbloat.net, linux-kernel@vger.kernel.org
To: Tianji Li <Tianji.Li@nuim.ie>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ksp.mff.cuni.cz ([195.113.26.206]:41602 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751281Ab1CHG63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2011 01:58:29 -0500
Content-Disposition: inline
In-Reply-To: <4D6FEFD4.9010608@nuim.ie>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu 2011-03-03 13:45:24, Tianji Li wrote:
> 
> 
> On 03/03/2011 12:16 PM, Rick Jones wrote:
> >>For wireless routers and cable home gateways especially, this research
> >>shows that the total un-managed buffers in your system should be less
> >>than 32.
> >
> >Would it be a good thing to start describing these queues not so much in
> >terms of packets but in terms of delay (or bandwidth X delay)?
> >
> 
> The unit of bandwidth is something like Mbps, that of delay can be
> second, so bandwidth X delay --> Mb, which is the unit of packet
> size. So both packets and delay should have the same effect for
> sizing buffers.

Bandwidth varies greatly with time. On cellphone, you can go from
5KB/sec GPRS to 300KB/sec HSDPA and back...
								Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
