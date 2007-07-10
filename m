From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 0/1] ixgbe: Support for Intel(R) 10GbE PCI Express adapters
 -	Take #2
Date: Tue, 10 Jul 2007 11:47:26 -0700
Message-ID: <4693D43E.6020407@intel.com>
References: <20070710174504.9615.10053.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ayyappan.Veeraiyan@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, arjan@linux.intel.com, hch@infradead.org,
	shemminger@linux-foundation.org, nhorman@tuxdriver.com,
	inaky@linux.intel.com, mb@bu3sch.de
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:57339 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754737AbXGJSr3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 14:47:29 -0400
In-Reply-To: <20070710174504.9615.10053.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ayyappan.Veeraiyan@intel.com wrote:
> This patch adds support for the Intel(R) 82598 based PCI Express 10GbE 
> adapters.
> 
> Please find the full driver as a patch to latest linus-2.6 tree here:
>     git-pull git://lost.foo-projects.org/~aveerani/git/linux-2.6 ixgbe

Andrew, I rebased this with the new driver code, so you might need to drop the 
old version.

Cheers,

Auke
