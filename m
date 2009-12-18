From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] iplink: add macvlan options for bridge mode
Date: Fri, 18 Dec 2009 18:37:49 +0100
Message-ID: <200912181837.50242.arnd@arndb.de>
References: <1258497551-25959-1-git-send-email-arnd@arndb.de> <200912181445.07756.arnd@arndb.de> <20091218092547.4ddfde58@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Anna Fischer <anna.fischer@hp.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick McHardy <kaber@trash.net>,
	Patrick Mullaney <pmullaney@novell.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	bridge@lists.linux-foundation.org,
	virtualization@linux-foundation.com,
	Jens Osterkamp <jens@linux.vnet.ibm.com>,
	Gerhard Stenzel <gerhard.stenzel@de.ibm.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:64318 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753783AbZLRRkT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 12:40:19 -0500
In-Reply-To: <20091218092547.4ddfde58@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 18 December 2009, Stephen Hemminger wrote:
> On Fri, 18 Dec 2009 14:45:07 +0100
> Arnd Bergmann <arnd@arndb.de> wrote:
> 
> > Ping!
> > 
> > Stephen, I submitted this twice but never heard back from you.
> > The changes to macvlan have been merged in 2.6.33-rc1, so it
> > would be good to have this included as well.
> > 
> >       Arnd
> > 
> 
> iproute gets updated (after patch is in upstream). I haven't started
> on the 2.6.33 version yet.

Ok, thanks for the info. Tell me when/if I should resubmit.
I also have another (smaller) patch that also accepts the same
options for the macvtap driver, which is not upstream.
Should I also send that when the kernel code hits net-next,
2.6.34-rc1 or 2.6.34?

	Arnd
