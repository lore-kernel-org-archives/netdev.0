From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 17/16] net: Disable netfilter sockopts when not in the
 initial network namespace
Date: Wed, 12 Sep 2007 04:59:03 -0700 (PDT)
Message-ID: <20070912.045903.104046208.davem@davemloft.net>
References: <m1y7fgu9ax.fsf_-_@ebiederm.dsl.xmission.com>
	<m1tzq4u92n.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ps0su8wv.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:38224
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1765857AbXILL7g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 07:59:36 -0400
In-Reply-To: <m1ps0su8wv.fsf_-_@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sat, 08 Sep 2007 15:47:12 -0600

> 
> Until we support multiple network namespaces with netfilter only allow
> netfilter configuration in the initial network namespace.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied to net-2.6.24, thanks.
