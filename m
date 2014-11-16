From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ieee802154: fix error handling in
 ieee802154fake_probe()
Date: Sun, 16 Nov 2014 14:45:46 -0500 (EST)
Message-ID: <20141116.144546.301780663386181251.davem@davemloft.net>
References: <1416006719-3450-1-git-send-email-khoroshilov@ispras.ru>
	<20141115071603.GA3481@omega>
	<B1D43522-B042-4D92-8F8A-D2AD89A3F0F9@holtmann.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.aring@gmail.com, khoroshilov@ispras.ru,
	linux-wpan@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: marcel@holtmann.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <B1D43522-B042-4D92-8F8A-D2AD89A3F0F9@holtmann.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marcel Holtmann <marcel@holtmann.org>
Date: Sat, 15 Nov 2014 16:58:28 +0900

> Dave, do you want to just take it via net-stable tree? We currently
> have no urgent bluetooth-stable tree patches pending.

Yeah I can do that, applied and queued up for -stable, thanks.
