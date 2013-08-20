From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: remember WOL preferences on driver load
Date: Tue, 20 Aug 2013 16:48:51 -0700 (PDT)
Message-ID: <20130820.164851.504886965054952877.davem@davemloft.net>
References: <1376730002-9235-1-git-send-email-lekensteyn@gmail.com>
	<20130820.151036.1067735437451172978.davem@davemloft.net>
	<20130820231201.GA31154@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lekensteyn@gmail.com, netdev@vger.kernel.org, nic_swsd@realtek.com,
	hayeswang@realtek.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48926 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751342Ab3HTXsy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 19:48:54 -0400
In-Reply-To: <20130820231201.GA31154@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Wed, 21 Aug 2013 01:12:01 +0200

> David Miller <davem@davemloft.net> :
> [...]
>> > Signed-off-by: Peter Wu <lekensteyn@gmail.com>
>> 
>> Can I get some reviews and Ack's for this?
> 
> It's more consistent with the {get / set}_wol parts of the driver and
> it's done in a way both Hayes and myself agreed on during the previous
> messages.
> 
> So you can consider it:
> 
> Acked-by: Francois Romieu <romieu@fr.zoreil.com>

Thanks, applied.
