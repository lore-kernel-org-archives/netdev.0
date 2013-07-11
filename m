From: Helmut Schaa <helmut.schaa@googlemail.com>
Subject: Re: [PATCH 2/2] drivers: net: phy: at803x: LED control via led subsystem
Date: Thu, 11 Jul 2013 21:04:58 +0200
Message-ID: <55a826d1-e3ca-4b68-b4cf-99afe9d75918@email.android.com>
References: <1373543855-31670-1-git-send-email-helmut.schaa@googlemail.com> <1373543855-31670-2-git-send-email-helmut.schaa@googlemail.com> <20130711.115455.1338073492446574779.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:56536 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756517Ab3GKTFL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 15:05:11 -0400
Received: by mail-wi0-f174.google.com with SMTP id k10so13025757wiv.7
        for <netdev@vger.kernel.org>; Thu, 11 Jul 2013 12:05:09 -0700 (PDT)
In-Reply-To: <20130711.115455.1338073492446574779.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>




David Miller <davem@davemloft.net> schrieb:

>From: Helmut Schaa <helmut.schaa@googlemail.com>
>Date: Thu, 11 Jul 2013 13:57:35 +0200
>
>> The AT8035 PHY allows to control the LED PIN behavior from software.
>> Expose this functionality by registering an LED device.
>> 
>> Signed-off-by: Helmut Schaa <helmut.schaa@googlemail.com>
>
>As a new feature, it is not appropriate to submit this change at this
>time.  Please resubmit this when the net-next tree opens up again.

OK, will do.
Helmut
