From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Fix long-standing regression in ser_gigaset ISDN
 driver
Date: Wed, 15 Jul 2015 17:25:26 -0700 (PDT)
Message-ID: <20150715.172526.958982413587459713.davem@davemloft.net>
References: <cover.1436826434.git.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pebolle@tiscali.nl, netdev@vger.kernel.org, hjlipp@web.de,
	linux-kernel@vger.kernel.org
To: tilman@imap.cc
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1436826434.git.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tilman Schmidt <tilman@imap.cc>
Date: Tue, 14 Jul 2015 00:37:13 +0200 (CEST)

> This series fixes a serious regression in the Gigaset M101 driver
> introduced in kernel release 3.10 and removes some unneeded code.
> 
> Please also queue up patch 1 of the series for inclusion in the
> stable/longterm releases 3.10 and later.

Series applied and patch #1 queued up for -stable, thanks.
