From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/3] net: maintain namespace isolation between vlan and real device
Date: Fri, 29 Jan 2010 11:12:05 +0100
Message-ID: <201001291112.05278.arnd@arndb.de>
References: <201001271104.20607.arnd@arndb.de> <201001271105.15733.arnd@arndb.de> <20100128.213344.226776729.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, kaber@trash.net, mst@redhat.com,
	herbert@gondor.apana.org.au, ogerlitz@voltaire.com,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756915Ab0A2KOz@vger.kernel.org>
In-Reply-To: <20100128.213344.226776729.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 29 January 2010, David Miller wrote:
> From: Arnd Bergmann <arnd@arndb.de>
> Date: Wed, 27 Jan 2010 11:05:15 +0100
> 
> > + * skb_dev_set -- assign a buffer to a new device
> 
> My english is terrible, but I think this should be
> "assign a new device to a buffer".

Right, that seems clearer.

> If you agree, please fix this up when you resubmit patches #1 and #2
> along with the fix you already plan to make to patch #3.

Ok, will do.

Thanks,

	Arnd
