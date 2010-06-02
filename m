From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 2/2] qlcnic: NIC Partitioning - Add non
 privileged mode support
Date: Wed, 02 Jun 2010 02:23:36 -0700 (PDT)
Message-ID: <20100602.022336.216737653.davem@davemloft.net>
References: <alpine.OSX.2.00.1006011428590.45836@macintosh-2.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amit.salecha@qlogic.com,
	ameen.rahman@qlogic.com
To: anirban.chakraborty@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33171
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756660Ab0FBJX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 05:23:26 -0400
In-Reply-To: <alpine.OSX.2.00.1006011428590.45836@macintosh-2.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Date: Tue, 1 Jun 2010 14:33:09 -0700

> Added support for NIC functions that work in non privileged mode where these 
> functions are privileged to do IO only, the control operations are handled via 
> privileged functions.
> Bumped up version number to 5.0.3.
> 
> Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>

Applied.
