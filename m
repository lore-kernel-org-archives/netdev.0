From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] connector: remove lazy workqueue creation
Date: Fri, 15 Oct 2010 17:49:42 +0400
Message-ID: <20101015134942.GA4422@ioremap.net>
References: <4CB8250A.7040902@kernel.org> <20101015130604.GA1751@ioremap.net> <4CB85945.8040801@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tservice.ru ([195.178.208.66]:54245 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755751Ab0JONtn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Oct 2010 09:49:43 -0400
Content-Disposition: inline
In-Reply-To: <4CB85945.8040801@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 15, 2010 at 03:38:13PM +0200, Tejun Heo (tj@kernel.org) wrote:
> Are you gonna route this patch?  If not, I can route it through
> workqueue tree.

If it does not depend on other work, I believe Dave will pull into
network tree.

-- 
	Evgeniy Polyakov
