From: Yavor Goulishev <yavor@simplifymedia.com>
Subject: RE: [Patch] Establishing more than 64K outgoing TCP connections
Date: Fri, 7 Nov 2008 02:40:32 -0500
Message-ID: <241CE5A1B2AFFA4987A663380D74C0BB3FFD15887D@MBX73.ad2.softcom.biz>
References: <241CE5A1B2AFFA4987A663380D74C0BB3FFD15887B@MBX73.ad2.softcom.biz>
	<20081106.230405.25075428.davem@davemloft.net>
	<241CE5A1B2AFFA4987A663380D74C0BB3FFD15887C@MBX73.ad2.softcom.biz>,<20081106.233010.138165162.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xsmtp19.mail2web.com ([168.144.250.190]:35208 "EHLO
	xsmtp19.mail2web.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750952AbYKGHlk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 02:41:40 -0500
In-Reply-To: <20081106.233010.138165162.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is not complain it is an observation.
And you are proving me right again!
But I'm done. You have it under control I'm sure.

--Yavor
________________________________________
From: David Miller [davem@davemloft.net]
Sent: Thursday, November 06, 2008 11:30 PM
To: Yavor Goulishev
Cc: netdev@vger.kernel.org
Subject: Re: [Patch] Establishing more than 64K outgoing TCP connections

From: Yavor Goulishev <yavor@simplifymedia.com>
Date: Fri, 7 Nov 2008 02:15:15 -0500

> Now I know why the kernel stays broken for so long.
> Some people don't want to admit their errors and fix the issues.
> Or at least explain them so that someone else can fix it for them.
> I hope you work on something really important!

Yes, a locally exploitable DoS that effects every Linux system
out there.

Are you done complaining now?
