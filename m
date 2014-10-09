From: Bruno Thomsen <bth@kamstrup.dk>
Subject: RE: Micrel KSZ8031 - phy link missing
Date: Thu, 9 Oct 2014 15:05:52 +0000
Message-ID: <915054555B5659448ACF8A70E114824D0163C79016@Exchange2010.kamstrup.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Bruno Thomsen <bth@kamstrup.dk>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kamstrup.com ([93.167.225.188]:65236 "EHLO
	mail.kamstrup.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757342AbaJIPFy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 11:05:54 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Angelo,

> It says no lease. But i verified that even setting a fixed ip, board is not reachable.
>
> Tracing inside phy.c i don't see the link to come up. Nothing seen on WS.
>
> As far as you know, there can be some bug open for davinci-emac and micrel ?


This sounds a lot like an issue I have just created and send a patch to fix.
Since I just joined this mail list it might have been eaten by Majordomo :)


[PATCH] phy/micrel: KSZ8031RNL RMII clock reconfiguration bug



Venlig hilsen / Best regards

Kamstrup A/S <http://www.kamstrup.dk> 
Bruno Thomsen
Development engineer
Technology

Kamstrup A/S
Industrivej 28
DK-8660 Skanderborg
Tel:	 +45 89 93 10 00	 
Fax:	 +45 89 93 10 01	 
Dir:	 +45 89 93 13 94	 
E-mail:	 bth@kamstrup.dk	 
Web:	 www.kamstrup.dk	 
