From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.23 0/2] cxgb3 - Fix dev->priv usage
Date: Wed, 29 Aug 2007 06:42:27 -0400
Message-ID: <46D54D93.5020100@garzik.org>
References: <46D4F12C.7090409@chelsio.com> <ada3ay26gys.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>
To: Roland Dreier <rdreier@cisco.com>, Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41088 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752589AbXH2Kma (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Aug 2007 06:42:30 -0400
In-Reply-To: <ada3ay26gys.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roland Dreier wrote:
> Looks OK to me but I would just roll up the second patch into the
> first patch and let Jeff merge it as one commit.  There's no point in
> creating an intermediate tree that doesn't build -- it just breaks git
> bisect for no useful purpose.

Agreed -- this needs to be in a single patch.

	Jeff



