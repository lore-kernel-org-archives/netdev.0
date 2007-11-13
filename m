From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [AF_PACKET] Fix minor code duplication
Date: Mon, 12 Nov 2007 21:05:40 -0800 (PST)
Message-ID: <20071112.210540.163820840.davem@davemloft.net>
References: <ygfpryjaoe9.fsf@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: urs.thuermann@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48950
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750778AbXKMFFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 00:05:41 -0500
In-Reply-To: <ygfpryjaoe9.fsf@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Urs Thuermann <urs.thuermann@gmx.de>
Date: 09 Nov 2007 08:06:38 +0100

> Simplify some code by eliminating duplicate if-else clauses in
> packet_do_bind().
> 
> Signed-off-by: Urs Thuermann <urs@isnogud.escape.de>

Applied, thanks Urs.
