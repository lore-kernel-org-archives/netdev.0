From: David Miller <davem@davemloft.net>
Subject: Re: sysctls
Date: Wed, 25 Apr 2007 13:10:09 -0700 (PDT)
Message-ID: <20070425.131009.35662849.davem@davemloft.net>
References: <20070425122924.88391585.akpm@linux-foundation.org>
	<20070425.130011.21926881.davem@davemloft.net>
	<m1irbkqkvp.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34851
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S2993053AbXDYUKD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 16:10:03 -0400
In-Reply-To: <m1irbkqkvp.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 25 Apr 2007 14:06:34 -0600

> David for clarity do you happen to know of anyone using binary
> sysctl values?

None at all.

> In particular is there any reason not to use CTL_UNNUMBERED
> for new networking sysctls?

Neil said he would send me a patch to do that.

Thanks.
