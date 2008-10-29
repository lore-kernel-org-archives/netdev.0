From: David Miller <davem@davemloft.net>
Subject: Re: FYI - TCP/IP thin stream latency
Date: Tue, 28 Oct 2008 22:13:51 -0700 (PDT)
Message-ID: <20081028.221351.172447876.davem@davemloft.net>
References: <20081022.221410.139436406.davem@davemloft.net>
	<Pine.LNX.4.64.0810231516220.7072@wrl-59.cs.helsinki.fi>
	<20081024075938.0dddb745@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, doug.leith@nuim.ie,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60459
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751433AbYJ2FON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 01:14:13 -0400
In-Reply-To: <20081024075938.0dddb745@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 24 Oct 2008 07:59:38 -0700

> I was reading "Removing Exponential Backoff from TCP" by Mondal and
> Kusmznovic at Northwesetern in ACM CCR. The paper tries to show that
> nothing breaks by getting rid of backoff. Interestingly, FreeBSD
> already doesn't do backoff until after 5th retry.

Cell phone network folks want this (or something like it) too.
