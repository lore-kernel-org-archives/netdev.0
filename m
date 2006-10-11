From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Customizable TCP backoff patch
Date: Tue, 10 Oct 2006 19:54:27 -0700 (PDT)
Message-ID: <20061010.195427.78163978.davem@davemloft.net>
References: <4522A88E.2070200@redhat.com>
	<20061004.000722.99203823.davem@davemloft.net>
	<452C4D12.9060102@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mgrondona@llnl.gov, behlendorf1@llnl.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:49066
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932430AbWJKCyY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Oct 2006 22:54:24 -0400
To: woodard@redhat.com
In-Reply-To: <452C4D12.9060102@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Actually, your entire patch uses spaces for indentation
of every new line added, not just those two new struct members
I pointed out.  Please use tabs for all of those cases.

Thanks a lot.
