From: Reyk Floeter <reyk@openbsd.org>
Subject: request for information about the "ath5k" licensing
Date: Wed, 5 Sep 2007 17:48:11 +0200
Message-ID: <20070905154811.GD1384@slim.vantronix.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from slim.vantronix.net ([83.246.81.11]:31457 "EHLO
	slim.vantronix.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756026AbXIEQIz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2007 12:08:55 -0400
Received: from slim.vantronix.net (reyk@localhost [127.0.0.1])
	by slim.vantronix.net (8.14.1/8.13.6) with ESMTP id l85FmBmI010698
	for <netdev@vger.kernel.org>; Wed, 5 Sep 2007 17:48:11 +0200 (CEST)
Received: (from reyk@localhost)
	by slim.vantronix.net (8.14.1/8.13.6/Submit) id l85FmB0a014392
	for netdev@vger.kernel.org; Wed, 5 Sep 2007 17:48:11 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

----- Forwarded message from Reyk Floeter <reyk@openbsd.org> -----

Date: Wed, 5 Sep 2007 17:18:23 +0200
From: Reyk Floeter <reyk@openbsd.org>
To: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-netdev@vger.kernel.org, jirislaby@gmail.com,
	moglen@softwarefreedom.org, mcgrof@gmail.com
Subject: request for information about the "ath5k" licensing
User-Agent: Mutt/1.5.12-2006-07-14

Hello!

I'm the author of the free hardware driver layer for wireless Atheros
devices in OpenBSD, also known as "OpenHAL".

I'm still trying to get an idea about the facts and the latest state
of the incidence that violated the copyright of my code, because I
just returned from vacation.

I'm very disappointed about this and I hope that it was a mistake,
because it is very unfair and malicious against me and the OpenBSD
community. I invested a lot of time to write the code and to make it
work with as many chipsets as possible. And during the last years, the
OpenBSD community helped to test and to improve the driver. I always
liked the idea to port it to other operating systems, but now somebody
harmed these efforts by violating the license.

Some time ago, I got repeated requests to change the license of the
code to GPL or to dual-license it but I always rejected these
requests. I clearly explained my reasons against dual-licensing in the
past. It needed some time, but it had seemed to me that the involved
people had finally accepted my decision. 

I do like to idea to port the free Atheros driver to other operating
systems in addition to OpenBSD, because it is a clear sign against
hardware companies attacking the free software "community" by
releasing binary-only driver objects instead of free code or hardware
documentation. I used to cooperate with the people working on the
madwifi port of "OpenHAL"; we exchanged ideas, bug fixes, and small
code snippets.  They sent me some bug reports and I also looked at
their changes and reported some functional problems. This was possible
because they kept the license in place. 

But now the Linux code is almost ready and somebody wants to cancel
any options to cooperate by locking me out with a prepended GPL and an
invalid copyright on top of it. I hope that this was not caused by the
same people.

Nevertheless, I'm cross-posting this mail to some lists and people
because I don't know the responsible persons. I have too many mails
about this issue in my inbox and it's very hard to filter out the
useful information.

Could you please give me some feedback about the latest state? Please
reply in private, I'm not subscribed to any of the Linux lists and I'm
rather interested in facts than in the usual trolling.

- Has this issue been fixed?

- Is there any repository available with the "ath5k" code using a
modified/"extended" license?

I don't know how to find the relevant bits in the various Linux git
repositories. Sorry, I don't get the structure of it. Are there any
other sources online except this diff on the linux kernel mailing
list?

- Are there any plans to release the "ath5k" code using a
modified/"extended" license?

Please let me know if it is planned to release my code with any other
license than the attached one. I also strongly disagree with the
concept of adding a new copyright and/or a GPL license on top of it -
it is still a derived work and a few stylistic changes, some code
shuffling, and some bug fixes don't allow to change the copyright. I
invested a lot of time and work to implement "OpenHAL" and it was much
more than just porting it. Please remember, it was a very hard task to
make it happen without any support from Atheros :(.

Please keep the following license and copyright notice in all affected
files and any derived work:

/*
 * Copyright (c) 2004, 2005, 2006, 2007 Reyk Floeter <reyk@openbsd.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

Thanks!
Reyk

-- 
/* .vantronix|secure systems - (research & development)
 * reyk floeter - friendly known free software engineer
 * reyk@vantronix.net - http://team.vantronix.net/reyk/
 */

----- End forwarded message -----
