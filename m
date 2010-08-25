From: David Miller <davem@davemloft.net>
Subject: Re: [patch] plip: remove superflous return
Date: Wed, 25 Aug 2010 16:37:11 -0700 (PDT)
Message-ID: <20100825.163711.229731651.davem@davemloft.net>
References: <20100824120105.GF29330@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@perches.com,
	kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59306
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751392Ab0HYXg4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 19:36:56 -0400
In-Reply-To: <20100824120105.GF29330@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Tue, 24 Aug 2010 14:01:05 +0200

> This return isn't reachable and it obscures the goto on the line before.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.
