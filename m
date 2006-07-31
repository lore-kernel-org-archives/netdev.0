From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][SECURITY] secmark: nul-terminate secdata
Date: Sun, 30 Jul 2006 20:47:03 -0700 (PDT)
Message-ID: <20060730.204703.78159806.davem@davemloft.net>
References: <Pine.LNX.4.64.0607281649440.20690@d.namei>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sds@tycho.nsa.gov, eparis@redhat.com,
	kaber@trash.net, chrisw@sous-sol.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:37554
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751003AbWGaDqx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jul 2006 23:46:53 -0400
To: jmorris@namei.org
In-Reply-To: <Pine.LNX.4.64.0607281649440.20690@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Morris <jmorris@namei.org>
Date: Fri, 28 Jul 2006 17:00:15 -0400 (EDT)

> The patch below fixes a problem in the iptables SECMARK target, where the 
> user-supplied 'selctx' string may not be nul-terminated.

Applied, thanks James.
