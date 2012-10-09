From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 4/6] VXLAN bases source UDP port based on flow to help
 the receiver to be able to load balance based on outer header flow.
Date: Tue, 9 Oct 2012 11:07:54 -0700
Message-ID: <20121009110754.57f229da@nehalam.linuxnetplumber.net>
References: <20121009175637.048993312@vyatta.com>
	<20121009175714.682992341@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55954 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756685Ab2JISIf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2012 14:08:35 -0400
In-Reply-To: <20121009175714.682992341@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit message messed up by quilt on this one, do you want to fix
or should I resubmit?
