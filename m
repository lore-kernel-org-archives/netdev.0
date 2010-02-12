From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] be2net: bug fix in be_read_eeprom
Date: Fri, 12 Feb 2010 12:28:52 -0800 (PST)
Message-ID: <20100212.122852.174797808.davem@davemloft.net>
References: <20100209035115.GA6577@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com, ajitkhaparde@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52512
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757470Ab0BLU2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2010 15:28:37 -0500
In-Reply-To: <20100209035115.GA6577@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitkhaparde@gmail.com>
Date: Tue, 9 Feb 2010 09:21:26 +0530

> The offset to read the eeprom data was missing and
> wrong eeprom data was being dumped. This patch fixes this.
> 
>>From Suresh R <sureshr@serverengines.com>
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

Applied.
