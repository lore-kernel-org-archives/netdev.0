From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 7254] New: leaving IP multicast group with
 incorrect imr_address unexpectedly succeeded
Date: Tue, 03 Oct 2006 13:47:57 -0700 (PDT)
Message-ID: <20061003.134757.122617543.davem@davemloft.net>
References: <20061003100750.902d4837.akpm@osdl.org>
	<OF6602D35D.A9238CC7-ON882571FC.00659110-882571FC.0065E706@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, Alexandra.Kossovsky@oktetlabs.ru,
	bugme-daemon@bugzilla.kernel.org, Konstantin.Petrov@oktetlabs.ru,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:16075
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030380AbWJCUrz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Oct 2006 16:47:55 -0400
To: dlstevens@us.ibm.com
In-Reply-To: <OF6602D35D.A9238CC7-ON882571FC.00659110-882571FC.0065E706@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Stevens <dlstevens@us.ibm.com>
Date: Tue, 3 Oct 2006 11:33:07 -0700

> If the index is set, it doesn't look up the address (which may be 
> expensive).
> If you want to look up by address, the index must be 0.
> 
> I wouldn't  call that a bug.

Me neither, Andrew please close this. :)
