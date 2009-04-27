From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] fix LL_MAX_HEADER for CONFIG_TR_MODULE
Date: Mon, 27 Apr 2009 02:36:31 -0700 (PDT)
Message-ID: <20090427.023631.164466930.davem@davemloft.net>
References: <20090427093207.GB9259@localhost.pp.htv.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bunk@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56253
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753686AbZD0Jgh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 05:36:37 -0400
In-Reply-To: <20090427093207.GB9259@localhost.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Adrian Bunk <bunk@kernel.org>
Date: Mon, 27 Apr 2009 12:32:07 +0300

> Unless I miss anything this should fix a bug.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

Good catch, applied, thanks Adrian.
