From: David Miller <davem@davemloft.net>
Subject: Re: DM9000: Fix revision ID for DM9000B
Date: Sat, 24 Oct 2009 06:53:18 -0700 (PDT)
Message-ID: <20091024.065318.113723076.davem@davemloft.net>
References: <20091023102631.373421273@fluff.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux@simtec.co.uk
To: ben@simtec.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34621
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753676AbZJXNwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2009 09:52:55 -0400
In-Reply-To: <20091023102631.373421273@fluff.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Dooks <ben@simtec.co.uk>
Date: Fri, 23 Oct 2009 11:26:31 +0100

> The DM9000B revision ID is 0x1A, not 0x1B as set in the curernt dm9000.h
> header.
> 
> Fix bug reported by Paolo Zebelloni.
> 
> Signed-off-by: Ben Dooks <ben@simtec.co.uk>
> Signed-off-by: Simtec Linux Team <linux@simtec.co.uk>

Applied, thanks.
