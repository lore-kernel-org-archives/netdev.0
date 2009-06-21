From: Bernard Pidoux F6BVP <f6bvp@free.fr>
Subject: [ROSE] 2.6.29 rose patch missing in 2.6.30
Date: Sun, 21 Jun 2009 12:42:58 +0200
Message-ID: <4A3E0EB2.7020106@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:35063 "EHLO smtp5-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752469AbZFUKnI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Jun 2009 06:43:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Problems with ROSE protocol came back with 2.6.30 kernel.
I discovered the reason.
Rose patch I submitted in November was applied in kernels until 2.6.29.4.
However this patch is not present in 2.6.30.

Is there any reason ?

Here are the reference to my patch and your acceptance message :

List:       linux-netdev
Subject:    [PATCH] [ROSE] zero length frame filtering in af_rose.c
From:       Bernard Pidoux <bernard.pidoux () upmc ! fr>
Date:       2008-11-24 21:49:40
Message-ID: 492B2174.1030503 () upmc ! fr
-----------
List:       linux-hams
Subject:    Re: [PATCH] [ROSE] zero length frame filtering in af_rose.c
From:       David Miller <davem () davemloft ! net>
Date:       2008-11-25 8:57:50
Message-ID: 20081125.005750.41495501.davem () davemloft ! net
[Download message RAW]


Patch applied, thank you.
--

Regards,


Bernard Pidoux
