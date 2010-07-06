From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] Documentation/isdn: CAPI controller interface
 amendment
Date: Mon, 05 Jul 2010 19:24:26 -0700 (PDT)
Message-ID: <20100705.192426.13754108.davem@davemloft.net>
References: <20100705-patch-isdn-00.tilman@imap.cc>
	<20100705-patch-isdn-01.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, hjlipp@web.de, keil@b1-systems.de,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tilman@imap.cc
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100705-patch-isdn-01.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tilman Schmidt <tilman@imap.cc>
Date: Tue,  6 Jul 2010 02:18:22 +0200 (CEST)

> Mention that the CAPI controller methods load_firmware() and
> reset_ctr() are asynchronous, and should signal completion.
> 
> Impact: documentation
> Signed-off-by: Tilman Schmidt <tilman@imap.cc>

Applied to net-next-2.6

Please stop using "Impact: " tags, I just edit them out when
I add your changes.
