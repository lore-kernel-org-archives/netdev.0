From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] isdn: eicon: fix sparse warning: make global
 functions static
Date: Tue, 16 Dec 2008 01:17:49 -0800 (PST)
Message-ID: <20081216.011749.124113130.davem@davemloft.net>
References: <49463d0c.09c5660a.36f7.ffffc710@mx.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kkeil@suse.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46790
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751225AbYLPJRr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 04:17:47 -0500
In-Reply-To: <49463d0c.09c5660a.36f7.ffffc710@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Eder <hannes@hanneseder.net>
Date: Thu, 11 Dec 2008 17:59:14 +0100

> Fix this sparse warnings by making the functions static:
 ...
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>

Applied, thanks Hannes.
