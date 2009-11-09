From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH 2/2] net/compat_ioctl: support SIOCWANDEV
Date: Mon, 09 Nov 2009 15:48:17 +0100
Message-ID: <m3eio7g3f2.fsf@intrepid.localdomain>
References: <1257530949-9695-1-git-send-email-arnd@arndb.de>
	<20091106.204753.223665411.davem@davemloft.net>
	<200911082231.48060.arnd@arndb.de> <200911082239.24698.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Daniel Walker <dwalker@fifo99.com>,
	linux-kernel@vger.kernel.org, hch@lst.de, netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754143AbZKIOsP@vger.kernel.org>
In-Reply-To: <200911082239.24698.arnd@arndb.de> (Arnd Bergmann's message of
	"Sun, 8 Nov 2009 22:39:24 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd@arndb.de> writes:

> This adds compat_ioctl support for SIOCWANDEV, which has
> always been missing.

It looks good, can't test at the moment.
-- 
Krzysztof Halasa
