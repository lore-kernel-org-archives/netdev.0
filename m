From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] bnx2/bnx2x: Unsupported Ethtool operations should
 return -EINVAL.
Date: Thu, 21 Oct 2010 20:00:35 -0700 (PDT)
Message-ID: <20101021.200035.104058353.davem@davemloft.net>
References: <1287696643-9695-1-git-send-email-jesse@nicira.com>
	<1287696643-9695-2-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44056
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754132Ab0JVDAM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 23:00:12 -0400
In-Reply-To: <1287696643-9695-2-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Thu, 21 Oct 2010 14:30:43 -0700

> Some cards don't support changing vlan offloading settings.  Make
> Ethtool set_flags return -EINVAL in those cases.
> 
> Reported-by: Ben Hutchings <bhutchings@solarflare.com>
> Signed-off-by: Jesse Gross <jesse@nicira.com>

Applied.
