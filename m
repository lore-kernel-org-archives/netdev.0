From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv6 bind to device issue
Date: Wed, 21 Apr 2010 22:58:46 -0700 (PDT)
Message-ID: <20100421.225846.32253820.davem@davemloft.net>
References: <1271767572-5282-1-git-send-email-jolsa@redhat.com>
	<4BCDEED3.7040901@hp.com>
	<20100421.225015.137831360.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jolsa@redhat.com, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48594
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751066Ab0DVF6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 01:58:41 -0400
In-Reply-To: <20100421.225015.137831360.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 21 Apr 2010 22:50:15 -0700 (PDT)

> Jiri please respin your patch with the argument order
> reversed so that we can make the inexpensive check before
> the expensive one.

Nevermind, I see you posted an updated version already,
which I've applied, thanks!
