From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] connector: remove lazy workqueue creation
Date: Fri, 15 Oct 2010 15:50:56 +0200
Message-ID: <4CB85C40.6070403@kernel.org>
References: <4CB8250A.7040902@kernel.org> <20101015130604.GA1751@ioremap.net> <4CB85945.8040801@kernel.org> <20101015134942.GA4422@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:35678 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754968Ab0JONvD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Oct 2010 09:51:03 -0400
In-Reply-To: <20101015134942.GA4422@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/15/2010 03:49 PM, Evgeniy Polyakov wrote:
> On Fri, Oct 15, 2010 at 03:38:13PM +0200, Tejun Heo (tj@kernel.org) wrote:
>> Are you gonna route this patch?  If not, I can route it through
>> workqueue tree.
> 
> If it does not depend on other work, I believe Dave will pull into
> network tree.

Nope, there's no dependency, so network tree then.

Thank you.

-- 
tejun
