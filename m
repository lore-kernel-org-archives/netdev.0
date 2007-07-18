From: David Miller <davem@davemloft.net>
Subject: Re: [PPPOL2TP 2/2]: Reset meta-data in xmit function
Date: Wed, 18 Jul 2007 02:04:57 -0700 (PDT)
Message-ID: <20070718.020457.32094353.davem@davemloft.net>
References: <469CB3E6.7070309@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51348
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753036AbXGRJE6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 05:04:58 -0400
In-Reply-To: <469CB3E6.7070309@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 17 Jul 2007 14:19:50 +0200

> [PPPOL2TP]: Reset meta-data in xmit function
> 
> Reset netfilter data and IP CB, fix dst_entry leak.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Good catch, applied, thanks Patrick.
