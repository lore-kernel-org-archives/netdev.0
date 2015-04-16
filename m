From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/1] stmmac: fix oops on rmmod after assigning ip
 addr
Date: Thu, 16 Apr 2015 12:30:19 -0400 (EDT)
Message-ID: <20150416.123019.1626957598986431327.davem@davemloft.net>
References: <1429060066-9156-2-git-send-email-pure.logic@nexus-software.ie>
	<20150416.120757.1014138571559447688.davem@davemloft.net>
	<552FE162.1060509@nexus-software.ie>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	andriy.shevchenko@linux.intel.com, hock.leong.kweh@intel.com,
	boon.leong.ong@intel.com, dan.odonovan@emutex.com,
	linux-kernel@vger.kernel.org
To: pure.logic@nexus-software.ie
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33619 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753033AbbDPQaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 12:30:22 -0400
In-Reply-To: <552FE162.1060509@nexus-software.ie>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bryan O'Donoghue <pure.logic@nexus-software.ie>
Date: Thu, 16 Apr 2015 17:20:50 +0100

> I'll spin again against :
> https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/

Currently active tree is 'net', not 'net-next'
