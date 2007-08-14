From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [3/4] 2.6.23-rc3: known regressions
Date: Wed, 15 Aug 2007 00:09:26 +0200
Message-ID: <20070814220926.GA3495@electric-eye.fr.zoreil.com>
References: <46C098FD.1030601@googlemail.com> <46C09C09.7010605@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@osdl.org>,
	"Daniel K." <daniel@cluded.net>, Shish <shish@shishnet.org>,
	Karl Meyer <adhocrocker@gmail.com>
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:43491 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757498AbXHNWNn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 18:13:43 -0400
Content-Disposition: inline
In-Reply-To: <46C09C09.7010605@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michal Piotrowski <michal.k.k.piotrowski@gmail.com> :
[...]
> Networking
> 
> Subject         : NETDEV WATCHDOG: eth0: transmit timed out
> References      : http://lkml.org/lkml/2007/8/13/737
> Last known good : ?
> Submitter       : Karl Meyer <adhocrocker@gmail.com>
> Caused-By       : ?
> Handled-By      : ?

  Handled-By      : romieu@fr.zoreil.com

> Status          : unknown

> Subject         : Weird network problems with 2.6.23-rc2
> References      : http://lkml.org/lkml/2007/8/11/40
> Last known good : ?
> Submitter       : Shish <shish@shishnet.org>
> Caused-By       : ?
> Handled-By      : ?
> Status          : unknown

The PR does not give any driver nor hardware detail. :o/

> Subject         : BUG: when using 'brctl stp'
> References      : http://lkml.org/lkml/2007/8/10/441
> Last known good : 2.6.23-rc1
> Submitter       : Daniel K. <daniel@cluded.net>
> Caused-By       : ?
> Handled-By      : ?

  Handled-By      : shemminger@linux-foundation.org

> Status          : unknown

  Status          : fix applied by David Miller

-- 
Ueimor
