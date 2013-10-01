From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] bgmac: add support for Byte Queue Limits
Date: Mon, 30 Sep 2013 22:11:23 -0700 (PDT)
Message-ID: <20130930.221123.1069371593385447255.davem@davemloft.net>
References: <1380455698-5897-1-git-send-email-hauke@hauke-m.de>
	<1380515684.3596.23.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hauke@hauke-m.de, zajec5@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42565 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751203Ab3JAFER (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 01:04:17 -0400
In-Reply-To: <1380515684.3596.23.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 29 Sep 2013 21:34:44 -0700

> On Sun, 2013-09-29 at 13:54 +0200, Hauke Mehrtens wrote:
>> This makes it possible to use some more advanced queuing
>> techniques with this driver.
>> 
>> When multi queue support will be added some changes to Byte Queue
>> handling is needed.
>> 
>> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
>> ---
> 
> Reviewed-by: Eric Dumazet <edumazet@google.com>

Applied.
