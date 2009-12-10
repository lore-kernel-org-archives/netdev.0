From: David Miller <davem@davemloft.net>
Subject: Re: [Uclinux-dist-devel] [PATCH v3] add the driver for Analog
 Devices Blackfin on-chip CAN controllers
Date: Thu, 10 Dec 2009 13:38:04 -0800 (PST)
Message-ID: <20091210.133804.21207458.davem@davemloft.net>
References: <4B20D39C.6030103@grandegger.com>
	<8bd0f97a0912100304p16087688q681710ba6b152c0c@mail.gmail.com>
	<4B20D881.3090003@grandegger.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vapier.adi@gmail.com, 21cnbao@gmail.com,
	socketcan-core@lists.berlios.de,
	uclinux-dist-devel@blackfin.uclinux.org, oe@port.de,
	netdev@vger.kernel.org
To: wg@grandegger.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44212
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755528AbZLJVh5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 16:37:57 -0500
In-Reply-To: <4B20D881.3090003@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfgang Grandegger <wg@grandegger.com>
Date: Thu, 10 Dec 2009 12:16:17 +0100

> I believe that it's good practice to hide such details by using proper
> accessor functions.

Absolutely, and positively %100 correct.
