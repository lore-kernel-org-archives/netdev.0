From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/3] r8152: modify the tx flow
Date: Tue, 29 Oct 2013 17:49:36 -0400 (EDT)
Message-ID: <20131029.174936.13317032766742363.davem@davemloft.net>
References: <1383033377-1178-1-git-send-email-hayeswang@realtek.com>
	<1383033377-1178-3-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1383033377-1178-3-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Tue, 29 Oct 2013 15:56:16 +0800

> Support stopping and waking tx queue. The maximum tx queue length
> is 60.

What is so special about the number 60?  It seems arbitrary, and if
it isn't arbitrary you haven't described why this value was choosen.

I've asked you politely last time around to significantly improve
the quality of your commit messages, and you haven't done this at
all.

I'm not applying any of these patches until your commit messages
properly describe your changes completely.
