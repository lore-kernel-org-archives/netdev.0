From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] inet6: Remove redundant unlikely()
Date: Fri, 10 Dec 2010 14:57:44 -0800 (PST)
Message-ID: <20101210.145744.13732812.davem@davemloft.net>
References: <1291905468-32174-1-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36410
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751570Ab0LJW5R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 17:57:17 -0500
In-Reply-To: <1291905468-32174-1-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Thu,  9 Dec 2010 15:37:48 +0100

> IS_ERR() already implies unlikely(), so it can be omitted here.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied.
