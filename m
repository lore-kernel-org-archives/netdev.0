From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 09/10] bnx2x: Added FW GRO bridging support
Date: Tue, 15 Jan 2013 20:56:28 -0800
Message-ID: <1358312188.19956.1.camel@edumazet-glaptop>
References: <50F50537.3030608@broadcom.com>
	 <1358260752.8744.5677.camel@edumazet-glaptop>
	 <50F56178.8000502@broadcom.com>
	 <20130115.150914.729025796621947521.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: yuvalmin@broadcom.com, netdev@vger.kernel.org, eilong@broadcom.com,
	ariele@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:56552 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757700Ab3APE4d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 23:56:33 -0500
Received: by mail-pa0-f50.google.com with SMTP id hz10so559513pad.23
        for <netdev@vger.kernel.org>; Tue, 15 Jan 2013 20:56:32 -0800 (PST)
In-Reply-To: <20130115.150914.729025796621947521.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-01-15 at 15:09 -0500, David Miller wrote:

> 
> I've merged your patch series as-is to net-next, please work on fixing
> the problems Eric has pointed out.

I have two fixes :

One in net/core/dev.c you probably can apply after usual review

One for bnx2x, I guess Broadcom guys need to check it.
