From: Xose Vazquez Perez <xose@wanadoo.es>
Subject: Re: [PATCH 2.6] pci.ids for e1000
Date: Fri, 12 Sep 2003 21:07:17 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F621965.4070106@wanadoo.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, linux-kernel <linux-kernel@vger.kernel.org>
Errors-to: netdev-bounce@oss.sgi.com
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

