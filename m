From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: add support for receive hashing
Date: Sun, 11 Jul 2010 15:34:37 -0700 (PDT)
Message-ID: <20100711.153437.02281455.davem@davemloft.net>
References: <AANLkTinRUJS6e8dwqvIMhtAUWBcj5oTk-D9MMrhbL9Bk@mail.gmail.com>
	<20100710.191242.70196353.davem@davemloft.net>
	<8628FE4E7912BF47A96AE7DD7BAC0AADDDE64704DC@SJEXCHCCR02.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: vladz@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52967
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752568Ab0GKWeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jul 2010 18:34:22 -0400
In-Reply-To: <8628FE4E7912BF47A96AE7DD7BAC0AADDDE64704DC@SJEXCHCCR02.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vladislav Zolotarov" <vladz@broadcom.com>
Date: Sun, 11 Jul 2010 03:02:17 -0700

>> We intend to use the card provided RSS hash to optimize GSO
>> flow comparisons at some point.
> 
> Could u explain what did u mean here, pls.? GSO is a Tx flow while
> RSS hash is generated for the ingress traffic.

I of course meant GRO, not GSO.
