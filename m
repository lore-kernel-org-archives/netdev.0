From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH] linux-firmware: Add a new bnx2x FW 7.0.20.0
Date: Tue, 14 Jun 2011 11:16:43 +0100
Message-ID: <1308046604.3450.7.camel@i7.infradead.org>
References: <201106141241.40764.vladz@broadcom.com>
	 <201106141257.40621.vladz@broadcom.com>
	 <1308045859.3450.6.camel@i7.infradead.org>
	 <201106141310.16440.vladz@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Yaniv Rosner <yaniv.rosner@broadcom.com>
To: Vlad Zolotarov <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:58886 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753764Ab1FNKQq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2011 06:16:46 -0400
In-Reply-To: <201106141310.16440.vladz@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-06-14 at 13:10 +0300, Vlad Zolotarov wrote:
> 
> Aha... Correct me if I got u wrong: to test it I need to manually copy
> the new .fw files into the /lib/firmware directory, install the clean
> net-next kernel with the driver that supports this new FW and it
> should work. Is it what u meant?

Right. Imagine that you have checked out the linux-firmware.git
repository directly into /lib/firmware, and nothing else has been
written there.

-- 
dwmw2

