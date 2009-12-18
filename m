From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iplink: add macvlan options for bridge mode
Date: Fri, 18 Dec 2009 09:25:47 -0800
Message-ID: <20091218092547.4ddfde58@nehalam>
References: <1258497551-25959-1-git-send-email-arnd@arndb.de>
	<1258497551-25959-5-git-send-email-arnd@arndb.de>
	<200912181445.07756.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
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
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34240 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752434AbZLRR0M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Dec 2009 12:26:12 -0500
In-Reply-To: <200912181445.07756.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 18 Dec 2009 14:45:07 +0100
Arnd Bergmann <arnd@arndb.de> wrote:

> Ping!
> 
> Stephen, I submitted this twice but never heard back from you.
> The changes to macvlan have been merged in 2.6.33-rc1, so it
> would be good to have this included as well.
> 
> 	Arnd
> 

iproute gets updated (after patch is in upstream). I haven't started
on the 2.6.33 version yet.
