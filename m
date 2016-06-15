From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] Remove the redundant initialization
 statement.
Date: Tue, 14 Jun 2016 22:28:23 -0700 (PDT)
Message-ID: <20160614.222823.1233657486694266740.davem@davemloft.net>
References: <1465808470-27424-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yuval.Mintz@qlogic.com
To: sudarsana.kalluru@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54144 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745AbcFOF2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 01:28:25 -0400
In-Reply-To: <1465808470-27424-1-git-send-email-sudarsana.kalluru@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Date: Mon, 13 Jun 2016 05:01:10 -0400

> The callback ".getcbx" is being initialized twice. This was introduced by
> the commit 0fdeb72aa6c9 ("qede: Add dcbnl support."). The patch removes the
> redundant initialization statement.
> 
> Reported-by: Julia Lawall <julia.lawall@lip6.fr> 
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
> Signed-off-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>

This subject line is not properly formed.

After "[PATCH ...] " you must provide a proper subsystem prefix specifier
followed by a colon character, and a SPACE.

Otherwise nobody reading the GIT shortlog has any idea where in the kernel
your change is taking place.

An appropriate subsystem prefix for this patch woult be "qede: ".
