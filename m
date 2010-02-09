From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 01/23 v3] mlx4_core: identify function as pf or vf
Date: Tue, 09 Feb 2010 13:41:06 +0000
Message-ID: <1265722866.2126.17.camel@achroite.uk.solarflarecom.com>
References: <49BFC313.1030901@mellanox.co.il>
	 <4B6AEDB0.2030105@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <rdreier@cisco.com>, general@lists.openfabrics.org,
	netdev@vger.kernel.org, liranl@mellanox.co.il,
	tziporet@mellanox.co.il
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:46385 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754300Ab0BINlL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2010 08:41:11 -0500
In-Reply-To: <4B6AEDB0.2030105@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The summary 'mlx4_core: identify function as pf or vf' doesn't match the
implementation.  Patch 14 'mlx4_core: Determine primary physical
function' makes it clear that a PF can also be a 'slave'.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

