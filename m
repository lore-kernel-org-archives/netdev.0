From: Daniel Walker <dwalker@fifo99.com>
Subject: Re: [PATCH 00/12] Gigaset driver patches for 2.6.32
Date: Mon, 07 Sep 2009 07:30:55 -0700
Message-ID: <1252333855.2139.15.camel__38454.1409359828$1252344968$gmane$org@desktop>
References: <20090906-patch-gigaset-00.tilman@imap.cc>
	 <1252286806.2139.1.camel@desktop>  <4AA4CD64.4070501@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	Hansjoerg Lipp <hjlipp@web.de>
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fifo99.com ([67.223.236.141]:45711 "EHLO fifo99.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753278AbZIGOaz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Sep 2009 10:30:55 -0400
In-Reply-To: <4AA4CD64.4070501@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-09-07 at 11:07 +0200, Tilman Schmidt wrote:
> Daniel,
> 
> thanks for taking a look at my patches.
> 
> On Sun, 06 Sep 2009 18:26:46 -0700, Daniel Walker wrote:
> > patches 6,7,10, and 12 all have checkpatch errors. Could you fix those? 
> 
> I have reissued patch 7, exchanging the "static" and "inline" keywords
> as requested.
> 
> The other patches I'd much prefer to keep as they are. The "ERRORs"
> checkpatch.pl reported for them are results of keeping to the existing
> formatting of the patched files. Completely reformatting them would
> cloud the actual changes made by the patches.

Yeah, it looks like the whole file needs a checkpatch clean up.. Sounds
like your not willing to do that? Usually if a checkpatch cleanup comes
first prior to all your other changes , it doesn't usually cloud the
rest of the changes..

Daniel

