From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: make neigh_ops constant
Date: Tue, 01 Sep 2009 17:45:31 -0700 (PDT)
Message-ID: <20090901.174531.236496673.davem@davemloft.net>
References: <20090901141319.6ce685e9@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40489
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755457AbZIBApQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 20:45:16 -0400
In-Reply-To: <20090901141319.6ce685e9@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 1 Sep 2009 14:13:19 -0700

> 
> These tables are never modified at runtime. Move to read-only
> section.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
