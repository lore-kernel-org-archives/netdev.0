From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.30-rc4] r8169: avoid losing MSI interrupts
Date: Tue, 26 May 2009 16:10:45 -0700 (PDT)
Message-ID: <20090526.161045.146842870.davem@davemloft.net>
References: <20090526.151410.109935435.davem@davemloft.net>
	<4A1C6FE9.1050003@googlemail.com>
	<20090526.154340.26952708.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mb@bu3sch.de, dave@thedillows.org, romieu@fr.zoreil.com,
	rsantos@grupopie.com, m.bueker@berlin.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: michael.riepe@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57979
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757900AbZEZXKq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 19:10:46 -0400
In-Reply-To: <20090526.154340.26952708.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 26 May 2009 15:43:40 -0700 (PDT)

> From: Michael Riepe <michael.riepe@googlemail.com>
> Date: Wed, 27 May 2009 00:40:41 +0200
> 
>> Michael Buesch already provided a patch against 2.6.29.4 that we both
>> tested. I doubt that it will apply to 2.6.27 cleanly, though.
> 
> Please forward a copy to me.

Nevermind, I was tired of waiting and fished it out of
patchwork.
