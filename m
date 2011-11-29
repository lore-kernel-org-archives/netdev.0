From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next-next 0/2] can: cc770: add support for the Bosch
 CC770 and Intel AN82527
Date: Tue, 29 Nov 2011 18:39:50 -0500 (EST)
Message-ID: <20111129.183950.1327835803051184146.davem@davemloft.net>
References: <1322136448-7311-1-git-send-email-wg@grandegger.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	socketcan-users@lists.berlios.de, boir1@yandex.ru,
	stanislavelensky@yahoo.com
To: wg@grandegger.com
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1322136448-7311-1-git-send-email-wg@grandegger.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wolfgang Grandegger <wg@grandegger.com>
Date: Thu, 24 Nov 2011 13:07:26 +0100

> Already since a while we have support for the Bosch CC770 and Intel
> AN82527 CAN controllers in our out-of-tree Socket-CAN repository.
> It would be nice if somebody could test the driver. Unfortunately,
> I currently do not have hardware at hand. I have not yet ported the
> OF platform driver as it needs further attaention due to the merge
> of the platform and OF platform interface.
> 
> Wolfgang Grandegger (2):
>   can: cc770: add driver core for the Bosch CC770 and Intel AN82527
>   can: cc770: legacy CC770 ISA bus driver

All applied, thank you.
