From: David Miller <davem@davemloft.net>
Subject: Re: [patch]startup race in hso driver
Date: Mon, 22 Dec 2008 19:54:20 -0800 (PST)
Message-ID: <20081222.195420.82285555.davem@davemloft.net>
References: <494A5728.9070908@option.com>
	<20081218.195251.186334055.davem@davemloft.net>
	<494B6776.4050309@option.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oliver@neukum.org, ajb@spheresystems.co.uk, gregkh@suse.de,
	netdev@vger.kernel.org, jgarzik@pobox.com,
	linux-usb@vger.kernel.org
To: D.Barow@option.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49249
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753980AbYLWDyS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2008 22:54:18 -0500
In-Reply-To: <494B6776.4050309@option.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis Joseph Barrow <D.Barow@option.com>
Date: Fri, 19 Dec 2008 10:20:54 +0100

> No no no.
> Please put it in Dave,
> Our internal tree is a completely seperately maintained hso module
> which is ifdeffed out of existance to compile back to 2.6.11.
> 
> It's typically made available at www.pharscape.org, the center
> of the universe for 3G on linux.

Ok, thanks for the clarification, I've put the patch back
into net-next-2.6
