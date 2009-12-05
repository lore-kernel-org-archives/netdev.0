From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: large packet loss take2 2.6.31.x
Date: Sat, 5 Dec 2009 14:57:35 +0100
Message-ID: <20091205135735.GA2619@ami.dom.local>
References: <20091127213640.GA2611@ami.dom.local>
 <81bfc67a0911271435g4106652bpe8c9ea07893d0ebd@mail.gmail.com>
 <20091127224206.GA3350@ami.dom.local>
 <81bfc67a0912031749y15faed66s9c8a924684c97a19@mail.gmail.com>
 <20091204090524.GB6478@ff.dom.local>
 <81bfc67a0912041028w16668d0cx4da04bee989eef4a@mail.gmail.com>
 <20091204204443.GA2736@ami.dom.local>
 <81bfc67a0912041507k6ef497f9w7b9294c90012e1a1@mail.gmail.com>
 <20091204234756.GA3517@ami.dom.local>
 <81bfc67a0912042306v573d79acw7f0ef3d051a41724@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frans Pop <elendil@planet.nl>, Andi Kleen <andi@firstfloor.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	e1000-devel@lists.sourceforge.net
To: Caleb Cushing <xenoterracide@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:40649 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754905AbZLEN6F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2009 08:58:05 -0500
Content-Disposition: inline
In-Reply-To: <81bfc67a0912042306v573d79acw7f0ef3d051a41724@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 05, 2009 at 02:06:09AM -0500, Caleb Cushing wrote:
> > I guess, you should better wait with new tests for some assistance
> > from e1000e maintainers - it seems they might be interested in some
> > specific dumps and registers - like in this #11998 case.
> 
> I reported here.
> 
> http://bugzilla.kernel.org/show_bug.cgi?id=14737

Please, remember to add at least standard things like dmesg, .config,
'lspci -vvv', /proc/interrupts etc. (linux-2.6/REPORTING_BUGS), and
maybe 'netstat -s' both for non-working and working case/boot.

And some summary (incl. the router type), so people don't have to
browse all this thread.

Jarek P.
