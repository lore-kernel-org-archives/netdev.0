From: Xose Vazquez Perez <xose@wanadoo.es>
Subject: Re: [PATCH 2.6] pci.ids for e1000
Date: Fri, 12 Sep 2003 22:15:07 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <3F62294B.2020105@wanadoo.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: netdev@oss.sgi.com, linux-kernel <linux-kernel@vger.kernel.org>
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:

> The general idea is to keep 2.4, 2.6, and pciids.sf.net in sync.

is there sync between 2.4, 2.6, and pciids.sf.net ?  ;-)

Linus and Marcelo should not accept patches against pci.ids,
all updates should go to pciids.sf.net. And every X time
to do a sync with 2.4 and 2.6.

It's the easiest, because otherwise is a chaos and it
takes too much work to do several merges:

2.4 <-> 2.6
2.4 <-> pciids
2.4 <-> 2.6

-- 
Que trabajen los romanos, que tienen el pecho de lata.
