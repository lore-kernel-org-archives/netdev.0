From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] eth16i: fix memory leak
Date: Wed, 14 Jul 2010 17:57:26 -0700 (PDT)
Message-ID: <20100714.175726.112610308.davem@davemloft.net>
References: <20100713114347.GK5658@bicker>
	<1279050563-15759-1-git-send-email-segooon@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, miku@iki.fi,
	shemminger@vyatta.com, eric.dumazet@gmail.com, tj@kernel.org,
	jpirko@redhat.com, netdev@vger.kernel.org
To: segooon@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38995
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756909Ab0GOA5L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 20:57:11 -0400
In-Reply-To: <1279050563-15759-1-git-send-email-segooon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kulikov Vasiliy <segooon@gmail.com>
Date: Tue, 13 Jul 2010 23:49:23 +0400

> Free allocated netdev if no probe is expected.
> 
> Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>

Applied.
