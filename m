From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 V3] kaweth: Fix locking to be SMP-safe
Date: Thu, 02 Apr 2009 01:10:01 -0700 (PDT)
Message-ID: <20090402.011001.03958848.davem@davemloft.net>
References: <49d3881d.7EinO6dA2s6BnVTa%Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	oliver@neukum.org
To: Larry.Finger@lwfinger.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33802
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752713AbZDBIKN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 04:10:13 -0400
In-Reply-To: <49d3881d.7EinO6dA2s6BnVTa%Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Larry Finger <Larry.Finger@lwfinger.net>
Date: Wed, 01 Apr 2009 10:28:29 -0500

> On an SMP system, the following message is printed. The patch below gets
> fixes the problem.
 ...

> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
 ...
> I had expected this to be 2.6.31 material, but Oliver requested that it be
> sent to Stable as well.

Applied, thanks.
