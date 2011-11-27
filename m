From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn/gigaset: report ISDN4Linux interface only once
Date: Sun, 27 Nov 2011 17:08:43 -0500 (EST)
Message-ID: <20111127.170843.1218883428304355076.davem@davemloft.net>
References: <20111127-patch-gigaset-01.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, hjlipp@web.de, keil@b1-systems.de,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tilman@imap.cc
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111127-patch-gigaset-01.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tilman Schmidt <tilman@imap.cc>
Date: Sun, 27 Nov 2011 18:39:22 +0100

> Move the "ISDN4Linux interface" message from device registration,
> where it is emitted for each device, to driver registration, where
> it is emitted only once, for consistency with the CAPI variant.
> 
> Signed-off-by: Tilman Schmidt <tilman@imap.cc>

Applied to net-next, thanks.
