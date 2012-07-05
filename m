From: David Miller <davem@davemloft.net>
Subject: Re: [net-next:master] general protection fault in __nla_put()
Date: Thu, 05 Jul 2012 14:22:00 -0700 (PDT)
Message-ID: <20120705.142200.1828988382587831318.davem@davemloft.net>
References: <20120705134857.GA14643@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wfg@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59246 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751727Ab2GEVWB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2012 17:22:01 -0400
In-Reply-To: <20120705134857.GA14643@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Steffen Klassert posted a patch which fixes this.
