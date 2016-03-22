From: Sebastian Frias <sf84@laposte.net>
Subject: Re: [PATCH] net: phy: at803x: don't depend on GPIOLIB
Date: Tue, 22 Mar 2016 15:39:15 +0100
Message-ID: <56F15913.5000204@laposte.net>
References: <56E99727.9040702@laposte.net> <56F05651.3030706@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>, mason <slash.tmp@free.fr>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	=?UTF-8?B?VXdlIA==?= =?UTF-8?B?S2xlaW5lLUvDtm5pZw==?=
	<u.kleine-koenig@pengutronix.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpoutz298.laposte.net ([178.22.154.198]:59373 "EHLO
	smtp.laposte.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754003AbcCVOjS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2016 10:39:18 -0400
Received: from smtp.laposte.net (localhost [127.0.0.1])
	by lpn-prd-vrout010 (Postfix) with ESMTP id 88EC3459C8E
	for <netdev@vger.kernel.org>; Tue, 22 Mar 2016 15:39:16 +0100 (CET)
Received: from lpn-prd-vrin003 (lpn-prd-vrin003.laposte [10.128.63.4])
	by lpn-prd-vrout010 (Postfix) with ESMTP id 6BAE845A1CC
	for <netdev@vger.kernel.org>; Tue, 22 Mar 2016 15:39:16 +0100 (CET)
Received: from lpn-prd-vrin003 (localhost [127.0.0.1])
	by lpn-prd-vrin003 (Postfix) with ESMTP id 4A55D48C422
	for <netdev@vger.kernel.org>; Tue, 22 Mar 2016 15:39:16 +0100 (CET)
In-Reply-To: <56F05651.3030706@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sergei,

On 03/21/2016 09:15 PM, Sergei Shtylyov wrote:
> 
>    Do you have the PHY that requires the GPIO reset workaround?

Unfortunately (or luckily :-) ) I don't have the faulty PHY, sorry.

Best regards,

Sebastian
