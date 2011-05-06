From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: Re: [PATCH] vmxnet3: Consistently disable irqs when taking
 adapter->cmd_lock
Date: Fri, 6 May 2011 12:21:12 -0700 (PDT)
Message-ID: <alpine.LRH.2.00.1105061206500.26660@sbhatewara-dev1.eng.vmware.com>
References: <1304706773-21348-1-git-send-email-roland@kernel.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	"pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Roland Dreier <roland@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([65.115.85.73]:38332 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755049Ab1EFTVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2011 15:21:10 -0400
In-Reply-To: <1304706773-21348-1-git-send-email-roland@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, 6 May 2011, Roland Dreier wrote:

> From: Roland Dreier <roland@purestorage.com>
> 
> Using the vmxnet3 driver produces a lockdep warning because

> Signed-off-by: Roland Dreier <roland@purestorage.com>


Roland, thanks for the analysis and the patch.

Signed-off-by: Shreyas N Bhatewara <sbhatewara@vmware.com>
