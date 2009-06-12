From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdev: dm9000: require compat net dev ops
Date: Thu, 11 Jun 2009 17:18:40 -0700 (PDT)
Message-ID: <20090611.171840.241102806.davem@davemloft.net>
References: <1244761350-2823-1-git-send-email-vapier@gentoo.org>
	<20090611.164908.11590745.davem@davemloft.net>
	<8bd0f97a0906111651r30310598la58774d8ee0bf3ad@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vapier.adi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39848
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750817AbZFLASi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 20:18:38 -0400
In-Reply-To: <8bd0f97a0906111651r30310598la58774d8ee0bf3ad@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier.adi@gmail.com>
Date: Thu, 11 Jun 2009 19:51:04 -0400

> On Thu, Jun 11, 2009 at 19:49, David Miller wrote:
>> From: Mike Frysinger Thu, 11 Jun 2009 19:02:30 -0400
>>> The dm9000 driver hasn't been upgraded yet, so select the compat net dev
>>> ops option for now.
>>
>> This config option no longer exists in the networking tree.
> 
> so compat support no longer exists, or dm9000 has been fixed, or
> dm9000 is broken, or dm9000 is dropped, or ...... ?

Compat support no longer exists, and dm9000 is converted in
net-next-2.6

