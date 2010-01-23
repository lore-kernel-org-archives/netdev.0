From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 31/31] CAPI: Officially claim char major 191
Date: Sat, 23 Jan 2010 12:24:30 +0000
Message-ID: <20100123122430.5a078b4a@lxorguk.ukuu.org.uk>
References: <cover.1264201406.git.jan.kiszka@web.de>
	<445e1bf881b6f8b6a5886d6eee70f6435a5619d6.1264201408.git.jan.kiszka@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>,
	linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	Alan Cox <alan@linux.intel.com>
To: Jan Kiszka <jan.kiszka@web.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755276Ab0AWMWa@vger.kernel.org>
In-Reply-To: <445e1bf881b6f8b6a5886d6eee70f6435a5619d6.1264201408.git.jan.kiszka@web.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 10 Jan 2010 14:21:31 +0100
Jan Kiszka <jan.kiszka@web.de> wrote:

> I found no trace of this mysterious "pcl181" device, neither in-tree nor
> out there in the wild. At the same time, the in-tree CAPI middleware is
> using major 191 for many years now and obviously without any conflict.
> Let's officially claim this major number.

This is not the way it should have been done but whoever needs spanking
got away with it years ago. Given that this seems the best way forward.

With LANANA hat on

Acked-by: Alan Cox <alan@linux.intel.com>
