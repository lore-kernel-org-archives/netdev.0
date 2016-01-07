From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: net-thunder: One check less in nicvf_register_interrupts() after
 error detection
Date: Thu, 7 Jan 2016 21:38:43 +0100
Message-ID: <568ECCD3.1020700@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
 <5685A273.6070607@users.sourceforge.net>
 <20160107110701.GE25086@rric.localdomain>
 <568EBCE7.4060502@users.sourceforge.net>
 <1452195846.4028.24.camel@perches.com>
 <568EC2FD.9000702@users.sourceforge.net>
 <1452196790.4028.33.camel@perches.com> <568EC56A.402@users.sourceforge.net>
 <1452198530.4028.43.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Robert Richter <rric@kernel.org>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Sunil Goutham <sgoutham@cavium.com>,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452198530.4028.43.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Some prefer that source code be "templatized" regardless
> of the number of exit points that any particular use of a
> specific function type.

This is another interesting view on involved implementation details.


> Some of your patches are converting these templatized
> functions to a different form for no added value.

Would you like to distinguish a bit more between my evolving
collection of update suggestions and the concrete proposal
for the function "nicvf_register_interrupts"?


> These patches make the local source code inconsistent
> and generally goes against the authors preferred style.

Which programming approach will be the leading one here finally?

Regards,
Markus
