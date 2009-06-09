From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: Re: [PATCH] hso: add missing last_rx setting
Date: Tue, 09 Jun 2009 17:05:37 +0300
Message-ID: <4A2E6C31.2070402@teltonika.lt>
References: <20090604155019.6660.33231.stgit@Programuotojas> <20090604.154204.163892378.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: j.dumon@option.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 81-7-68-229.static.zebra.lt ([81.7.68.229]:35476 "EHLO
	teltonika.lt" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750995AbZFIOFi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jun 2009 10:05:38 -0400
In-Reply-To: <20090604.154204.163892378.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
> Date: Thu, 04 Jun 2009 18:50:23 +0300
> 
>> Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
> 
> The core networking does this now for the drivers, they
> don't need to do it themselves any longer.

Where? I couldn't find it even in net-next...

> Your patch is not correct.
> 
