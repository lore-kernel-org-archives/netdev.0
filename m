From: poma <pomidorabelisima@gmail.com>
Subject: Re: [PATCH net 1/1] r8169: fix sleepable allocation during netdevice
 stats retrieval.
Date: Tue, 8 Sep 2015 08:36:08 +0200
Message-ID: <55EE81D8.4010008@gmail.com>
References: <55E9A518.3080906@gmail.com>
 <20150904.113657.2146226970417029162.davem@davemloft.net>
 <20150904205904.GA32346@electric-eye.fr.zoreil.com>
 <20150906101954.GE30539@calimero.vinschen.de> <55ED391C.2090906@gmail.com>
 <20150907085023.GA17511@calimero.vinschen.de> <55EDA281.3030706@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Mike Massonnet <m8t@gandi.net>,
	Benedikt Meurer <benedikt.meurer@unix-ag.uni-siegen.de>,
	Bernhard Walle <bernhard.walle@gmx.de>,
	Hendrik Scholz <hscholz@raisdorf.net>,
	Florian Rivoal <frivoal@xfce.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:35363 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751455AbbIHGgN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2015 02:36:13 -0400
Received: by wicge5 with SMTP id ge5so103433602wic.0
        for <netdev@vger.kernel.org>; Mon, 07 Sep 2015 23:36:12 -0700 (PDT)
In-Reply-To: <55EDA281.3030706@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2nd batch:
0001-r8169-decouple-the-counters-data-and-the-device-priv.patch
0002-r8169-use-a-single-condition-to-check-the-completion.patch
0003-r8169-increase-the-lifespan-of-the-hardware-counters.patch
- the noise is still present
