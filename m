From: Andrew Ruder <andy@aeruder.net>
Subject: Re: [PATCH] net: sk == 0xffffffff fix - not for commit
Date: Fri, 24 Jan 2014 07:38:31 -0600
Message-ID: <20140124133831.GB20804@gmail.com>
References: <1386589672-5830-1-git-send-email-andrzej.p@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	Kyungmin Park <kyungmin.park@samsung.com>,
	Felipe Balbi <balbi@ti.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Michal Nazarewicz <mina86@mina86.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Andrzej Pietrasiewicz <andrzej.p@samsung.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1386589672-5830-1-git-send-email-andrzej.p@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Actually found what looks to be a fix for this in another thread.

http://www.mail-archive.com/linux-kernel@vger.kernel.org/msg574770.html
http://gcc.gnu.org/bugzilla/show_bug.cgi?id=58854

Cheers,
Andy
