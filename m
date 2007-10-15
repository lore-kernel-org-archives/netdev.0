From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH v3 0/4] FEC - fast ethernet controller for mpc52xx
Date: Mon, 15 Oct 2007 15:06:04 -0400
Message-ID: <4713BA1C.2050604@pobox.com>
References: <20071014075511.GC3000@nd47.coderock.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: galak@kernel.crashing.org, linuxppc-dev@ozlabs.org,
	grant.likely@secretlab.ca, tnt@246tnt.com, netdev@vger.kernel.org
To: Domen Puncer <domen.puncer@telargo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52668 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752494AbXJOTGJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 15:06:09 -0400
In-Reply-To: <20071014075511.GC3000@nd47.coderock.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Domen Puncer wrote:
> Hello!
> 
> If there are no objections, I would like to get this merged
> when bestcomm goes in (any time now?).
> 
> It's split into four parts:
> 1 - device tree
> 2 - small bestcomm change
> 3 - the actual driver
> 4 - phy part of the driver

patches #3 and #4 need to be combined together.

Are the arch people OK with patches #1 and #2?

	Jeff



