From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix 2.6.34-rc1 regression in disable_ipv6 support
Date: Thu, 09 Dec 2010 12:20:52 -0800 (PST)
Message-ID: <20101209.122052.39177935.davem@davemloft.net>
References: <m139q6ahld.fsf@fess.ebiederm.org>
	<20101209111611.1d2e6e2b@nehalam>
	<m1y67y3fqf.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, brian.haley@hp.com, netdev@vger.kernel.org,
	maheshkelkar@gmail.com, lorenzo@google.com,
	yoshfuji@linux-ipv6.org, stable@kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43004
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754145Ab0LIUUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 15:20:25 -0500
In-Reply-To: <m1y67y3fqf.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 09 Dec 2010 11:31:36 -0800

> You fix the problem.  You introduced the regression, and you didn't test
> that keeping addresses actually worked.  This is not the first patch
> that has been applied to fix regressions in this area.

Exactly, I fully agree with Eric.
