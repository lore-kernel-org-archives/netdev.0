From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] ISDN patches for net-next
Date: Mon, 21 Jan 2013 17:38:10 -0500 (EST)
Message-ID: <20130121.173810.2229077237480842007.davem@davemloft.net>
References: <20130121-patch-isdn-00.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, hjlipp@web.de, keil@b1-systems.de,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tilman@imap.cc
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130121-patch-isdn-00.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tilman Schmidt <tilman@imap.cc>
Date: Mon, 21 Jan 2013 22:57:20 +0100 (CET)

> here's a series of six patches to the ISDN subsystem. Please consider
> for application to net-next. The last one should also go into -stable
> and is tagged "CC: stable" accordingly.

Patches 1-5 applied to net-next, patch 6 applied to 'net' and queued
up for -stable.

We don't have changes bypass 'net' and go into stable from net-next
like you intended.  We also don't use CC: stable for networking
patches, you ask me to queue them up into my -stable patch queue
for networking instead.

Thanks.
