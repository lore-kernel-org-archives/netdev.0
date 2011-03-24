From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [PATCH v2 08/16] mlx4_en: Reporting HW revision in ethtool -i
Date: Thu, 24 Mar 2011 03:40:19 +0000
Message-ID: <1300938019.26693.528.camel@localhost>
References: <4D89B16F.4040008@mellanox.co.il>
	 <1300889054.26693.527.camel@localhost>
	 <953B660C027164448AE903364AC447D20705BE28@mtldag01.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eugenia Emantayev <eugenia@mellanox.co.il>
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:24929 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933081Ab1CXDkX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2011 23:40:23 -0400
In-Reply-To: <953B660C027164448AE903364AC447D20705BE28@mtldag01.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-03-23 at 15:10 +0000, Yevgeny Petrilin wrote:
> > 
> > This is an abuse of the ethtool_drvinfo::driver field.
> > 
> > Your users can use lspci -v, can't they?
> > 
> I don't think there is a problem here.
> We have always reported the HW model via Ethtool, we just expanded the information
> we provide.
> Our users prefer to see the information in ethtool.

I can provide a patch for David if you won't.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

