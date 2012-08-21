From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: iputils git tree
Date: Tue, 21 Aug 2012 10:47:21 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1208211041410.1100@frira.zrqbmnf.qr>
References: <201203182107.43855.vapier@gentoo.org> <20120801040957.GL11095@morgul.net> <5018AE19.7050002@linux-ipv6.org> <201208011121.35902.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Noah Meyerhans <frodo@morgul.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from seven.medozas.de ([5.9.24.206]:56444 "EHLO seven.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751542Ab2HUIrZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Aug 2012 04:47:25 -0400
In-Reply-To: <201208011121.35902.vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 2012-08-01 17:21, Mike Frysinger wrote:

>On Wednesday 01 August 2012 00:18:33 YOSHIFUJI Hideaki wrote:
>> In fact my first motivation was to integrate Debian, Fedora and
>> other distro updates in to single source.  I sometimes look
>> into their sources and integrate some of their changes.
>
>i think we should get bugging the maintainers to push to you rather than 
>forcing you to go out and locate patches.  especially when the patches are 
>often times underdocumented.

And half of iputils has been superseded or thelike.

* arping -> th's arping http://freecode.com/projects/arping
* ifenslave -> bonding's sysfs files
* tftpd -> tftpd-hpa
