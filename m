From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Add basic support for smsc9311 in smsc911x Driver
Date: Tue, 22 Feb 2011 09:37:47 -0800 (PST)
Message-ID: <20110222.093747.226762308.davem@davemloft.net>
References: <20110215125708.79245312@SyspacSw04>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fernando@syspac.com.br
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43889
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754677Ab1BVRhK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 12:37:10 -0500
In-Reply-To: <20110215125708.79245312@SyspacSw04>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fernando <fernando@syspac.com.br>
Date: Tue, 15 Feb 2011 12:57:08 -0200

> 
> The smsc9311 chip is an switch chip with 3 ports that have almost the same
> register structure of the LAN9115. There are some differences in IRQ regs,
> but that doesn't seem to be a problem right now.
> 
> This patch was tested on a Torpedo (OMAP35x) based board and is based on
> v2.6.38-rc4.

Please submit your patch properly as per the directions in
Documentation/SubmittingPatches, in particular you forgot to
provide a proper Signed-off-by: line in your commit message.
