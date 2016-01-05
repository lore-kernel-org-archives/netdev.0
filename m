From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch v2] qlcnic: fix a timeout loop
Date: Tue, 5 Jan 2016 22:30:54 +0300
Message-ID: <20160105193054.GW5177@mwanda>
References: <20151215135616.GA18851@mwanda>
 <568A717D.6070309@univ-nantes.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dept-GELinuxNICDev@qlogic.com,
	Manish Chopra <manish.chopra@qlogic.com>,
	netdev@vger.kernel.org,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: Yann Dupont - Veille Techno <veilletechno-irts@univ-nantes.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:17487 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751667AbcAETbL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 14:31:11 -0500
Content-Disposition: inline
In-Reply-To: <568A717D.6070309@univ-nantes.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No.  This patch is a suspend resume thing and your bug is something
else.  Honestly, this patch is a static checker fix and I doubt it has
much real worl impact at all.

regards,
dan carpenter
