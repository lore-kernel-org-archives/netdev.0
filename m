From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: smsc: Implement PHY config_init for LAN87xx
Date: Thu, 27 Sep 2012 18:28:56 -0400 (EDT)
Message-ID: <20120927.182856.865110466151216008.davem@davemloft.net>
References: <1348604262-21522-1-git-send-email-marex@denx.de>
	<CAP9ODKqC5PhkWxuMsFgA019-wZuygr_hhEme_xyP9dy4C6bLmw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marex@denx.de, netdev@vger.kernel.org, chohnstaedt@innominate.com,
	fabio.estevam@freescale.com, peppe.cavallaro@st.com
To: otavio@ossystems.com.br
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58997 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755304Ab2I0W26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 18:28:58 -0400
In-Reply-To: <CAP9ODKqC5PhkWxuMsFgA019-wZuygr_hhEme_xyP9dy4C6bLmw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Otavio Salvador <otavio@ossystems.com.br>
Date: Thu, 27 Sep 2012 15:21:37 -0300

> On Tue, Sep 25, 2012 at 5:17 PM, Marek Vasut <marex@denx.de> wrote:
>> The LAN8710/LAN8720 chips do have broken the "FlexPWR" smart power-saving
>> capability. Enabling it leads to the PHY not being able to detect Link when
>> cold-started without cable connected. Thus, make sure this is disabled.
>>
>> Signed-off-by: Marek Vasut <marex@denx.de>
> 
> Acked-by: Otavio Salvador <otavio@ossystems.com.br>

Applied, thanks.
