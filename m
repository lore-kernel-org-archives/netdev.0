From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macvlan: add tap device backend
Date: Thu, 06 Aug 2009 20:20:33 -0700 (PDT)
Message-ID: <20090806.202033.232151260.davem@davemloft.net>
References: <1249595428-21594-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net,
	shemminger@linux-foundation.org, mst@redhat.com,
	herbert@gondor.apana.org.au, ogerlitz@voltaire.com,
	anna.fischer@hp.com, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, evb@yahoogroups.com
To: arnd@arndb.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756977AbZHGDUZ@vger.kernel.org>
In-Reply-To: <1249595428-21594-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Thu,  6 Aug 2009 21:50:28 +0000

> This is a first prototype of a new interface into the network
> stack, to eventually replace tun/tap and the bridge driver
> in certain virtual machine setups.

I don't know enough to say how good a solution this is for
the problem, but I certainly like this driver for it's
utter simplicity and minimalness.
