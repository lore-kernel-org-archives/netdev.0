From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] wan: pci200syn needs capability.h
Date: Tue, 13 Oct 2009 19:19:47 +0200
Message-ID: <m33a5n5hzg.fsf@intrepid.localdomain>
References: <20091013162312.8b93998b.sfr@canb.auug.org.au>
	<20091013100016.3c9bfad7.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, davem@davemloft.net,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20091013100016.3c9bfad7.randy.dunlap@oracle.com> (Randy Dunlap's
	message of "Tue, 13 Oct 2009 10:00:16 -0700")
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Randy Dunlap <randy.dunlap@oracle.com> writes:

> Driver is missing header file capability.h:
>
> drivers/net/wan/pci200syn.c:212: error: implicit declaration of function 'capable'
> drivers/net/wan/pci200syn.c:212: error: 'CAP_NET_ADMIN' undeclared (first use in this function)

Thanks, but I think a patch for a bunch of WAN drivers has been already
posted.
-- 
Krzysztof Halasa
