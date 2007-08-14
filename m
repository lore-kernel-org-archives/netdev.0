From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: Distributed storage. Mirroring to any number of devices.
Date: Tue, 14 Aug 2007 19:20:49 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0708141919230.10912@fbirervta.pbzchgretzou.qr>
References: <20070814162918.GA30330@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070814162918.GA30330@2ka.mipt.ru>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Aug 14 2007 20:29, Evgeniy Polyakov wrote:
>
>I'm pleased to announce second release of the distributed storage
>subsystem, which allows to form a storage on top of remote and local
>nodes, which in turn can be exported to another storage as a node to
>form tree-like storages.

I'll be quick: what is it good for, are there any users, and what could
it have to do with DRBD and all the other distribution storage talk
that has come up lately (namely NBD w/Raid1)?


	Jan
-- 
