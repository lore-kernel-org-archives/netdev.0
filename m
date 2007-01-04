From: Pierre TARDY <pierre.tardy@freescale.com>
Subject: Re: [PATCH] SMSC LAN911x and LAN921x vendor driver
Date: Thu, 04 Jan 2007 15:42:55 +0100
Message-ID: <459D126F.5080300@freescale.com>
References: <11674964822991-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ian Saturley <ian.saturley@smsc.com>,
	Bahadir Balban <bahadir.balban@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:33404 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964881AbXADOnI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jan 2007 09:43:08 -0500
To: Steve Glendinning <steve.glendinning@smsc.com>
In-Reply-To: <11674964822991-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steve Glendinning wrote:
> Attached is a driver for SMSC's LAN911x and LAN921x families of embedded
> ethernet controllers.  There is an existing smc911x driver in the tree;
> this is intended to replace it.
>
> This driver contains workarounds for all known hardware issues, and has
> been tested on all flavours of the chip on multiple architectures.
>
> Dustin McIntire (the author of the smc911x driver) has expressed his
> support for switching to this driver.
>
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
>   
This patch has just been tested on my Freescale mx31 board, with a 
smsc9117, and Linux version 2.6.16.19.
I agree to include it in mainstream.
old smc911x is restricted to one architecture (PXA) and one chip (9118).

Acked-by: Pierre Tardy <tardyp@gmail.com>




-- 
Pierre Tardy

