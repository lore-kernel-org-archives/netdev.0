From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] selinux: fix 2.6.20-rc6 build when no xfrm
Date: Fri, 26 Jan 2007 19:04:07 -0800 (PST)
Message-ID: <20070126.190407.126764080.davem@davemloft.net>
References: <45BA331B.9090701@trustedcs.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, eparis@redhat.com,
	sgrubb@redhat.com, sds@tycho.nsa.gov, jmorris@namei.org,
	chanson@trustedcs.com, michal.k.k.piotrowski@gmail.com
To: vyekkirala@trustedcs.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51824
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751880AbXA0DEI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jan 2007 22:04:08 -0500
In-Reply-To: <45BA331B.9090701@trustedcs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Venkat Yekkirala <vyekkirala@trustedcs.com>
Date: Fri, 26 Jan 2007 10:58:03 -0600

> This patch is an incremental fix to the flow_cache_genid
> patch for selinux that breaks the build of 2.6.20-rc6 when
> xfrm is not configured.
> 
> Signed-off-by: Venkat Yekkirala <vyekkirala@TrustedCS.com>

Applied, thanks for taking care of this.
