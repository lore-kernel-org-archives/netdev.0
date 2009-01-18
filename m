From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] via-velocity: fix hot spin
Date: Sat, 17 Jan 2009 23:07:39 -0800 (PST)
Message-ID: <20090117.230739.259050243.davem@davemloft.net>
References: <49724A37.3040703@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37559
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755450AbZARHHh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2009 02:07:37 -0500
In-Reply-To: <49724A37.3040703@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Sat, 17 Jan 2009 22:14:31 +0100

> while(--j >= 0) keeps spinning when j is unsigned:
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Applied, thanks Roel.
