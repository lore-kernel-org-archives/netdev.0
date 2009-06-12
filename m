From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: [PATCH] netdev: dm9000: require compat net dev ops
Date: Thu, 11 Jun 2009 20:47:58 -0400
Message-ID: <8bd0f97a0906111747q3e3bdd2ck29eca4dd24a1883@mail.gmail.com>
References: <1244761350-2823-1-git-send-email-vapier@gentoo.org>
	<20090611.164908.11590745.davem@davemloft.net> <8bd0f97a0906111651r30310598la58774d8ee0bf3ad@mail.gmail.com>
	<20090611.171840.241102806.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.28]:48944 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751892AbZFLAsQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 20:48:16 -0400
Received: by yw-out-2324.google.com with SMTP id 5so1264617ywb.1
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2009 17:48:18 -0700 (PDT)
In-Reply-To: <20090611.171840.241102806.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 11, 2009 at 20:18, David Miller wrote:
> From: Mike Frysinger Thu, 11 Jun 2009 19:51:04 -0400
>> On Thu, Jun 11, 2009 at 19:49, David Miller wrote:
>>> From: Mike Frysinger Thu, 11 Jun 2009 19:02:30 -0400
>>>> The dm9000 driver hasn't been upgraded yet, so select the compat net dev
>>>> ops option for now.
>>>
>>> This config option no longer exists in the networking tree.
>>
>> so compat support no longer exists, or dm9000 has been fixed, or
>> dm9000 is broken, or dm9000 is dropped, or ...... ?
>
> Compat support no longer exists, and dm9000 is converted in
> net-next-2.6

works for me.  said patch works fine for 2.6.30.
-mike
