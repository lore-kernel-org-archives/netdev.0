From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] RPS: enables setting CONFIG_RPS config
 option.
Date: Tue, 23 Nov 2010 12:12:41 -0800 (PST)
Message-ID: <20101123.121241.48503028.davem@davemloft.net>
References: <AANLkTikLP0_Xphc7ECwF7yuffqU0dmw1QWdpc36dfMAT@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33371
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751893Ab0KWUMQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Nov 2010 15:12:16 -0500
In-Reply-To: <AANLkTikLP0_Xphc7ECwF7yuffqU0dmw1QWdpc36dfMAT@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <ramirose@gmail.com>
Date: Tue, 23 Nov 2010 22:10:37 +0200

>  The patch enables setting CONFIG_RPS config option for
>  Receive packet steering (net/Kconfig.).

We do not want it to be choosable by the user.

CONFIG_RPS acts merely a dependency description mechanism, nothing
more.
