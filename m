From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sweep-up some straglers in strlcpy conversion
 of .get_drvinfo routines
Date: Wed, 16 Nov 2011 17:49:17 -0500 (EST)
Message-ID: <20111116.174917.1609330445189751935.davem@davemloft.net>
References: <20111116005953.E05A42900404@tardy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nico@fluxnic.net, peppe.cavallaro@st.com
To: raj@tardy.cup.hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57762 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753154Ab1KPWvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 17:51:23 -0500
In-Reply-To: <20111116005953.E05A42900404@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: raj@tardy.cup.hp.com (Rick Jones)
Date: Tue, 15 Nov 2011 16:59:53 -0800 (PST)

> From: Rick Jones <rick.jones2@hp.com>
> 
> Convert some remaining straglers' .get_drvinfo routines to use strlcpy
> rather than strcpy/strncpy.
> 
> Signed-off-by: Rick Jones <rick.jones2@hp.com>

Applied, thanks Rick.
