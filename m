From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gre: fix ToS/DiffServ inherit bug
Date: Tue, 14 Jul 2009 09:43:23 -0700 (PDT)
Message-ID: <20090714.094323.247351883.davem@davemloft.net>
References: <20090714153648.GC8461@urbino.open.ch>
	<20090714.093433.216171575.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: voyo@no-ip.pl, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	kaber@trash.net
To: aj@open.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36163
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753373AbZGNQnS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2009 12:43:18 -0400
In-Reply-To: <20090714.093433.216171575.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 14 Jul 2009 09:34:33 -0700 (PDT)

> From: Andreas Jaggi <aj@open.ch>
> Date: Tue, 14 Jul 2009 17:36:48 +0200
> 
>> Fixes two bugs:
>> - ToS/DiffServ inheritance was unintentionally activated when using impair fixed ToS values
>> - ECN bit was lost during ToS/DiffServ inheritance
>> 
>> Signed-off-by: Andreas Jaggi <aj@open.ch>

In case it wasn't clear, I've applied this patch.
