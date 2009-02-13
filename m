From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TG3: limit reaches -1
Date: Thu, 12 Feb 2009 16:33:33 -0800 (PST)
Message-ID: <20090212.163333.196549487.davem@davemloft.net>
References: <4992AD3A.7000301@gmail.com>
	<1234384817.14439.131.camel@HP1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roel.kluin@gmail.com, netdev@vger.kernel.org,
	akpm@linux-foundation.org, mcarlson@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46838
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752299AbZBMAdj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 19:33:39 -0500
In-Reply-To: <1234384817.14439.131.camel@HP1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 11 Feb 2009 12:40:16 -0800

> 
> On Wed, 2009-02-11 at 02:49 -0800, Roel Kluin wrote:
> > With while (limit--) { ... } limit reaches -1, so 0 means success.
> > 
> > Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> 
> Acked-by: Michael Chan <mchan@broadcom.com>

Applied.
