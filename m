From: Rick Jones <rick.jones2@hp.com>
Subject: Re: expected behavior of PF_PACKET on NETIF_F_HW_VLAN_RX device?
Date: Thu, 01 Nov 2007 15:04:12 -0700
Message-ID: <472A4D5C.2070301@hp.com>
References: <4729EAFF.9050606@candelatech.com>	<18218.18134.353553.189622@zeus.sw.starentnetworks.com>	<472A49BD.6000802@hp.com> <20071101.145956.63020380.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: djohnson+linux-kernel@sw.starentnetworks.com,
	greearb@candelatech.com, shemminger@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	bguo@sw.starentnetworks.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:36260 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753582AbXKAWEO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2007 18:04:14 -0400
In-Reply-To: <20071101.145956.63020380.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Rick Jones <rick.jones2@hp.com>
> Date: Thu, 01 Nov 2007 14:48:45 -0700
> 
> 
>>One could I suppose try to ammend the information passed to allow
>>tcpdump to say "oh, this was a tx packet on the same machine on
>>which I am tracing so don't worry about checksum mismatch"
> 
> 
> We do this already!

I'll try to go pester folks in tcpdump-workers then.

rick
