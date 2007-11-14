From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix warning for token-ring from sysctl checker
Date: Tue, 13 Nov 2007 21:15:40 -0800 (PST)
Message-ID: <20071113.211540.97775009.davem@davemloft.net>
References: <20071113072313.GB16842@lixom.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ebiederm@xmission.com
To: olof@lixom.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48494
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750722AbXKNFPl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 00:15:41 -0500
In-Reply-To: <20071113072313.GB16842@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Olof Johansson <olof@lixom.net>
Date: Tue, 13 Nov 2007 01:23:13 -0600

> As seen when booting ppc64_defconfig:
> 
> sysctl table check failed: /net/token-ring .3.14 procname does not match binary path procname
> 
> 
> Signed-off-by: Olof Johansson <olof@lixom.net>

Patch applied, thanks Olof.
