From: David Miller <davem@davemloft.net>
Subject: Re: BUG when unloading bonding on 2.6.29-rc7-git3
Date: Wed, 11 Mar 2009 09:22:02 -0700 (PDT)
Message-ID: <20090311.092202.126273766.davem@davemloft.net>
References: <49B6CA4A.2040506@mandriva.org>
	<1236727393.7958.38.camel@Maple>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tmb@mandriva.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: john.dykstra1@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753755AbZCKQWc@vger.kernel.org>
In-Reply-To: <1236727393.7958.38.camel@Maple>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Dykstra <john.dykstra1@gmail.com>
Date: Tue, 10 Mar 2009 23:23:13 +0000

> ipv6:  Fix BUG when disabled ipv6 module is unloaded
> 
> Do not try to "uninitialize" ipv6 if its initialization had been skipped
> because module parameter disable=1 had been specified.
> 
> Reported-by:  Thomas Backlund <tmb@mandriva.org>
> Signed-off-by: John Dykstra <john.dykstra1@gmail.com>

I'm going to apply this by hand.

But if you are going to submit patches in the future you have to fix
the corruptions and mangling that your email client does to them.
