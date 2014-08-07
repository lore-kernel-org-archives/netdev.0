From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH net-next v4 0/6] net-timestamp: new tx tstamps and tcp
Date: Thu, 07 Aug 2014 16:09:26 -0700
Message-ID: <87lhqzkic9.fsf@tassilo.jf.intel.com>
References: <1407204710-21778-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, richardcochran@gmail.com
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:18245 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751237AbaHGXKU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Aug 2014 19:10:20 -0400
In-Reply-To: <1407204710-21778-1-git-send-email-willemb@google.com> (Willem de
	Bruijn's message of "Mon, 4 Aug 2014 22:11:44 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Willem de Bruijn <willemb@google.com> writes:

> Extend socket tx timestamping:
> - allow multiple types of software timestamps aside from send (1)
> - add software timestamp on enter packet scheduling (4)
> - add software timestamp for TCP (5)
> - add software timestamp for TCP on ACK (6)

Is there any freely available reference library or tool to make use of
all these new time stamps?

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only
