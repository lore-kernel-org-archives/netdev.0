From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] hso driver fix for big endian machines.
Date: Mon, 12 Jan 2009 21:56:59 -0800 (PST)
Message-ID: <20090112.215659.140891938.davem@davemloft.net>
References: <496B5ABE.2060406@option.com>
	<200901121604.41727.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: D.Barow@option.com, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, P.Hardwick@option.com
To: oliver@neukum.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42934
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753815AbZAMF47 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 00:56:59 -0500
In-Reply-To: <200901121604.41727.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oliver@neukum.org>
Date: Mon, 12 Jan 2009 16:04:40 +0100

> Am Monday 12 January 2009 15:59:10 schrieb Denis Joseph Barrow:
> > This patch is against 2.6.29-rc1 I hope it'll apply to other trees if neccessary.
> > Filip Aben says this fix is neccessary for big endian machines.
> 
> He's correct. They are needed.

Patch applied, thanks everyone.
