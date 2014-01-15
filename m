From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: throughput problems with realtek
Date: Thu, 16 Jan 2014 00:51:23 +0100
Message-ID: <20140115235123.GA6773@electric-eye.fr.zoreil.com>
References: <CACE9dm_3jw08_dfXRJRMQ=r4X1NZ1kHF6TZopFSNy3k+DCKgTA@mail.gmail.com>
 <52D6B5F4.1060201@hp.com>
 <CACE9dm92Wu=XwCChXJjjsz=FEWAgJW-1iLRw5-d4c5ZTCYVe3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rick Jones <rick.jones2@hp.com>, nic_swsd@realtek.com,
	netdev@vger.kernel.org, l.moiseichuk@samsung.com
To: Dmitry Kasatkin <dmitry.kasatkin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:47764 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752089AbaAOXvu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 18:51:50 -0500
Content-Disposition: inline
In-Reply-To: <CACE9dm92Wu=XwCChXJjjsz=FEWAgJW-1iLRw5-d4c5ZTCYVe3w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dmitry Kasatkin <dmitry.kasatkin@gmail.com> :
[...]
> I do not see any link speed changes... it stays the same...
> The same problem is visible on absolutely different computers.

No netdev watchdog message either ?

A serving 8168c does not seem to fluctuate (3.12.5, Intel 82578 client).
My hardware is a bit old though. Please send XID message from the r8169
driver. It should be seen in dmesg.

Thanks.

-- 
Ueimor
