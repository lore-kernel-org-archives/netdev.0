From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: namespace support requires network modules to say "GPL"
Date: Sat, 1 Dec 2007 19:23:41 +0000
Message-ID: <20071201192341.6750fbdb@the-village.bc.nu>
References: <m163zi9425.fsf@ebiederm.dsl.xmission.com>
	<47515D39.9030900@rtr.ca>
	<20071201111736.297dd99a@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mark Lord <lkml@rtr.ca>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Greg Kroah-Hartman <gregkh@suse.de>, Greg KH <greg@kroah.com>,
	Tejun Heo <htejun@gmail.com>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, cornelia.huck@de.ibm.com,
	stern@rowland.harvard.edu, kay.sievers@vrfy.org,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:48268 "EHLO
	the-village.bc.nu" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752731AbXLAT2U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 14:28:20 -0500
In-Reply-To: <20071201111736.297dd99a@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Then init_net needs to be not GPL limited. Sorry, we need to allow
> non GPL network drivers.  There is a fine line between keeping the

Why - they aren't exactly likely to be permissible by law

> binary seething masses from accessing random kernel functions, and allowing
> reasonable (but still non GPL) things like ndiswrapper to use network
> device interface.

Its up to the ndiswrapper authors how the licence their code, but they
should respect how we licence ours.
