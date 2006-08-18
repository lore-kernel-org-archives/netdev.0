From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: bonding: cannot remove certain named devices
Date: Fri, 18 Aug 2006 01:34:43 +0100
Message-ID: <1155861283.15195.112.camel@localhost.localdomain>
References: <20060816133811.GA26471@nostromo.devel.redhat.com>
	 <Pine.LNX.4.58.0608161636250.2044@be1.lrz>
	 <1155799783.7566.5.camel@capoeira>
	 <20060817.162340.74748342.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: xavier.bestel@free.fr, 7eggert@gmx.de, notting@redhat.com,
	cate@debian.org, 7eggert@elstempel.de, shemminger@osdl.org,
	mitch.a.williams@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from outpipe-village-512-1.bc.nu ([81.2.110.250]:30909 "EHLO
	lxorguk.ukuu.org.uk") by vger.kernel.org with ESMTP id S932212AbWHRAOs
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 20:14:48 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060817.162340.74748342.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ar Iau, 2006-08-17 am 16:23 -0700, ysgrifennodd David Miller:
> Nobody in their right mind puts a space in their network device name.

It works fine. Been there done that. I'm probably not in my right mind
but it causes no problems. Nor btw does UTF-8 naming which is handy if
you want to name your devices in Japanese or Arabic...

> All you "name purists", go rename the block device name that is used
> for your root partition to something with a space in it

Works fine. It doesn't work fine for non root volumes (except by label)
because of the fstab format but root is ok !

Alan
