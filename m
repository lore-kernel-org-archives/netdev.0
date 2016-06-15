From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [very-RFC 0/8] TSN driver for the kernel
Date: Wed, 15 Jun 2016 09:11:53 +0200
Message-ID: <20160615071153.GC2919@netboy>
References: <1465686096-22156-1-git-send-email-henrik@austad.us>
 <20160613114713.GA9544@localhost.localdomain>
 <20160613130059.GA20320@sisyphus.home.austad.us>
 <20160613193208.GA2441@netboy>
 <20160614093000.GB21689@sisyphus.home.austad.us>
 <20160614182615.GA2741@netboy>
 <20160614203810.GC21689@sisyphus.home.austad.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-media@vger.kernel.org,
	alsa-devel@vger.kernel.org, netdev@vger.kernel.org,
	Arnd Bergmann <arnd@linaro.org>
To: Henrik Austad <henrik@austad.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35915 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752574AbcFOHL6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 03:11:58 -0400
Content-Disposition: inline
In-Reply-To: <20160614203810.GC21689@sisyphus.home.austad.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 14, 2016 at 10:38:10PM +0200, Henrik Austad wrote:
> Where is your media-application in this?

Um, that *is* a media application.  It plays music on the sound card.

> You only loop the audio from 
> network to the dsp, is the media-application attached to the dsp-device?

Sorry, I thought the old OSS API would be familiar and easy to
understand.  The /dev/dsp is the sound card.

Thanks,
Richard
