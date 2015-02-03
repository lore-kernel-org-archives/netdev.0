From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/3] net-timestamp: blinding
Date: Mon, 02 Feb 2015 18:47:19 -0800 (PST)
Message-ID: <20150202.184719.89281223998414188.davem@davemloft.net>
References: <1422642573-6126-1-git-send-email-willemb@google.com>
	<20150201112931.GA4323@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: willemb@google.com, netdev@vger.kernel.org, luto@amacapital.net
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49989 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933774AbbBCCrX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 21:47:23 -0500
In-Reply-To: <20150201112931.GA4323@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Sun, 1 Feb 2015 12:29:31 +0100

> On Fri, Jan 30, 2015 at 01:29:30PM -0500, Willem de Bruijn wrote:
>> Two issues were raised during recent timestamping discussions:
>> 1. looping full packets on the error queue exposes packet headers
>> 2. TCP timestamping with retransmissions generates many timestamps
> 
> For the series,
> 
> Acked-by: Richard Cochran <richardcochran@gmail.com>

Series applied, thanks everyone.
