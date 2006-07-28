From: David Miller <davem@davemloft.net>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Thu, 27 Jul 2006 22:34:00 -0700 (PDT)
Message-ID: <20060727.223400.97292695.davem@davemloft.net>
References: <20060727165121.GA6637@2ka.mipt.ru>
	<20060727205651.GA29953@ms2.inr.ac.ru>
	<20060728051723.GA11210@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, rusty@rustcorp.com.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:42380
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751654AbWG1FeB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jul 2006 01:34:01 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060728051723.GA11210@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Fri, 28 Jul 2006 09:17:25 +0400

> What would you expect from non-preemptible kernel? Hard lockup, no acks,
> no soft irqs.

Why does pressing Ctrl-Z on the user process stop kernel soft irq
processing?


