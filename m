From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/2] be2net: add unlock on error path
Date: Sat, 29 May 2010 00:20:10 -0700 (PDT)
Message-ID: <20100529.002010.123974681.davem@davemloft.net>
References: <20100526144634.GL22515@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sathyap@serverengines.com, subbus@serverengines.com,
	sarveshwarb@serverengines.com, ajitk@serverengines.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38366
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751806Ab0E2HT7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 May 2010 03:19:59 -0400
In-Reply-To: <20100526144634.GL22515@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Wed, 26 May 2010 16:46:35 +0200

> The unlock accidentally got removed from the error path in dd131e76e5:
> "be2net: Bug fix to avoid disabling bottom half during firmware upgrade."
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.
