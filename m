From: Bernhard Schmidt <berni@birkenwald.de>
Subject: Re: [Bugme-new] [Bug 12877] New: tg3: eth0 transit timed out,
	resetting -> dead NIC
Date: Wed, 1 Apr 2009 00:16:21 +0200
Message-ID: <20090331221621.GA1324@schleppi.birkenwald.de>
References: <bug-12877-10286@http.bugzilla.kernel.org/> <20090315143214.90c71fb7.akpm@linux-foundation.org> <1237238601.8839.85.camel@HP1> <49C01F7F.9030306@birkenwald.de> <20090319165842.GA10819@xw6200.broadcom.net> <20090322132121.GA7871@pest> <20090331162617.GB15533@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Chan <mchan@broadcom.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.svr02.mucip.net ([83.170.6.69]:42510 "EHLO
	mailout.mucip.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752248AbZCaWQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 18:16:29 -0400
Content-Disposition: inline
In-Reply-To: <20090331162617.GB15533@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 31, 2009 at 09:26:17AM -0700, Matt Carlson wrote:

> > I'm now switching to eth1.
> Bernhard, any word on what happened?

So far so good. In the last week my watchdog (cannot reach the default
gateway) triggered once, but since there were no "PCI Memory Mapped IO
Disabled!!!!" messages in the logfile I assume that was a real network
problem. Since the box ran fine for months initially and the first two
occurances of this issue were two weeks apart I cannot say for sure, but
it definitely feels better than the "once in two days" in the end.

Bernhard
