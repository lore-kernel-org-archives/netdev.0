From: David Miller <davem@davemloft.net>
Subject: Re: [RFC, PATCH 0/7] net, compat_ioctl: move handlers to
 net/socket.c
Date: Sun, 08 Nov 2009 20:55:46 -0800 (PST)
Message-ID: <20091108.205546.141103466.davem@davemloft.net>
References: <1257530949-9695-1-git-send-email-arnd@arndb.de>
	<20091106.204753.223665411.davem@davemloft.net>
	<200911082231.48060.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, hch@lst.de, netdev@vger.kernel.org,
	dwmw2@infradead.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754114AbZKIEzW@vger.kernel.org>
In-Reply-To: <200911082231.48060.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Sun, 8 Nov 2009 22:31:47 +0100

> Any opinion on how to proceed with the ATM stuff? From my
> point of view, I'm fine with having moved it out of fs/compat_ioctl.c,
> but it's still a bit silly to have two half-complete implementations.

I haven't looked at that stuff yes, you can be sure it's in
my queue :-)
