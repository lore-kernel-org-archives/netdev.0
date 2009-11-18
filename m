From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/3] macvlan: Reflect macvlan packets meant for other macvlan devices
Date: Wed, 18 Nov 2009 15:44:24 +0100
Message-ID: <200911181544.24275.arnd@arndb.de>
References: <1258497551-25959-1-git-send-email-arnd@arndb.de> <200911181047.07974.arnd@arndb.de> <m1pr7fdhkx.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick McHardy <kaber@trash.net>,
	Patrick Mullaney <pmullaney@novell.com>,
	Edge Virtual Bridging <evb@yahoogroups.com>,
	Anna Fischer <anna.fischer@hp.com>,
	bridge@lists.linux-foundation.org,
	virtualization@lists.linux-foundation.org,
	Jens Osterkamp <jens@linux.vnet.ibm.com>,
	Gerhard Stenzel <gerhard.stenzel@de.ibm.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:54528 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757002AbZKROoc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 09:44:32 -0500
In-Reply-To: <m1pr7fdhkx.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 18 November 2009, Eric W. Biederman wrote:
> Please copy and ideally share code with the veth driver for recycling a skb.
> There are bunch of little things you have to do to get it right.  As I recally
> I was missing a few details in my original patch.

Ok, thanks for the hint!

	Arnd <><
