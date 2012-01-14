From: Darren Hart <dvhart@linux.intel.com>
Subject: Re: [PATCH] pch_gbe: Use a randomly generated MAC instead of failing
 probe
Date: Sat, 14 Jan 2012 07:45:05 -0800
Message-ID: <4F11A301.4010904@linux.intel.com>
References: <132d2a41a089905de3147b4656e350608aa7fd6f.1326523495.git.dvhart@linux.intel.com> <20120114.001525.2158050844390627233.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, arjan@linux.intel.com,
	alan@linux.intel.com, tomoya.rohm@gmail.com,
	jeffrey.t.kirsher@intel.com, paul.gortmaker@windriver.com,
	jdmason@kudzu.us, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:32885 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755035Ab2ANP4F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Jan 2012 10:56:05 -0500
In-Reply-To: <20120114.001525.2158050844390627233.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 01/14/2012 12:15 AM, David Miller wrote:
> From: Darren Hart <dvhart@linux.intel.com>
> Date: Fri, 13 Jan 2012 22:44:55 -0800
> 
>> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com> (commit_signer:1/3=33%,commit_signer:1/8=12%)
> 
> BTW, please try to figure out where this "commit_signer" stuff came from.
> 
> It ended up corrupting the CC: list of your posting too.

Sorry about that, I caught it too late.

-- 
Darren Hart
Intel Open Source Technology Center
Yocto Project - Linux Kernel
