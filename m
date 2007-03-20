From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC][PATCH -mm take3 6/6][resend] add ioctls for
 adding/removing target
Date: Tue, 20 Mar 2007 09:59:50 -0700
Message-ID: <20070320095950.72a2ea62@freekitty>
References: <45FFCF31.3040000@bx.jp.nec.com>
	<45FFD4C1.7000103@bx.jp.nec.com>
	<b6fcc0a0703200550p441bb01fkfebb4102ef8e57d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Keiichi KII" <k-keiichi@bx.jp.nec.com>, mpm@selenic.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Alexey Dobriyan" <adobriyan@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965412AbXCTRAB@vger.kernel.org>
In-Reply-To: <b6fcc0a0703200550p441bb01fkfebb4102ef8e57d@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since these are network device related ioctl's it might be clearer (and easier)
to use network device (struct ifreq) style ioctl's.


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
