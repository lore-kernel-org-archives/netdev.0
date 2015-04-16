From: Bryan O'Donoghue <pure.logic@nexus-software.ie>
Subject: Re: [PATCH v2 1/1] stmmac: fix oops on rmmod after assigning ip addr
Date: Thu, 16 Apr 2015 17:20:50 +0100
Message-ID: <552FE162.1060509@nexus-software.ie>
References: <1429060066-9156-1-git-send-email-pure.logic@nexus-software.ie>	<1429060066-9156-2-git-send-email-pure.logic@nexus-software.ie> <20150416.120757.1014138571559447688.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	andriy.shevchenko@linux.intel.com, hock.leong.kweh@intel.com,
	boon.leong.ong@intel.com, dan.odonovan@emutex.com,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound-smtp05.blacknight.com ([81.17.249.38]:42709 "EHLO
	outbound-smtp05.blacknight.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752834AbbDPQUx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 12:20:53 -0400
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id 08E4D98D98
	for <netdev@vger.kernel.org>; Thu, 16 Apr 2015 16:20:52 +0000 (UTC)
In-Reply-To: <20150416.120757.1014138571559447688.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/04/15 17:07, David Miller wrote:
> This patch does not apply to the current tree, please respin.
>

/facepalm

Did this against :
https://github.com/torvalds/linux.git

I'll spin again against :
https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/
