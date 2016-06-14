From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [very-RFC 0/8] TSN driver for the kernel
Date: Tue, 14 Jun 2016 19:04:44 +0200
Message-ID: <20160614170442.GA1825@netboy>
References: <1465686096-22156-1-git-send-email-henrik@austad.us>
 <20160613114713.GA9544@localhost.localdomain>
 <20160613195136.GC2441@netboy>
 <20160614121844.54a125a5@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Henrik Austad <henrik@austad.us>, linux-kernel@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@vger.kernel.org,
	netdev@vger.kernel.org, henrk@austad.us,
	Arnd Bergmann <arnd@linaro.org>
To: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34255 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751153AbcFNREz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 13:04:55 -0400
Content-Disposition: inline
In-Reply-To: <20160614121844.54a125a5@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 14, 2016 at 12:18:44PM +0100, One Thousand Gnomes wrote:
> On Mon, 13 Jun 2016 21:51:36 +0200
> Richard Cochran <richardcochran@gmail.com> wrote:
> > 
> > Actually, we already have support for tunable clock-like HW elements,
> > namely the dynamic posix clock API.  It is trivial to write a driver
> > for VCO or the like.  I am just not too familiar with the latest high
> > end audio devices.
> 
> Why high end ? Even the most basic USB audio is frame based and
> isosynchronous to the USB clock. It also reports back the delay
> properties.

Well, I guess I should have said, I am not too familiar with the
breadth of current audio hardware, high end or low end.  Of course I
would like to see even consumer devices work with AVB, but it is up to
the ALSA people to make that happen.  So far, nothing has been done,
afaict.

Thanks,
Richard
