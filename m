From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: deadlocks if use htb
Date: Wed, 14 Jan 2009 12:36:23 +0000
Message-ID: <20090114123623.GA6117@ff.dom.local>
References: <20081010090426.GA6054@ff.dom.local> <Pine.LNX.4.64.0901110438050.16453@nacho.alt.net> <20090114063909.GA4234@ff.dom.local> <200901141417.58667.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Caputo <ccaputo@alt.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Badalian Vyacheslav <slavon@bigtelecom.ru>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f31.google.com ([209.85.219.31]:45346 "EHLO
	mail-ew0-f31.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754097AbZANMga (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 07:36:30 -0500
Content-Disposition: inline
In-Reply-To: <200901141417.58667.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2009 at 02:17:58PM +0200, Denys Fedoryschenko wrote:
> I will try that patches too, when i got this message, after 3 minutes i got 
> crash of my router :-) after working around 17 hours :-(
> There is 3 of them by the way, 2 fixes also.
> 
> hrtimer: removing all ur callback modes
> hrtimer: removing all ur callback modes, fix hotplug
> hrtimer: removing all ur callback modes, fix

Yes, it's a very nasty bug which, BTW you reported the first AFAIK,
but I hope it's really gone with these patches.

Thanks,
Jarek P.
