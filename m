From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: net-thunder: One check less in nicvf_register_interrupts() after
 error detection
Date: Thu, 7 Jan 2016 20:56:45 +0100
Message-ID: <568EC2FD.9000702@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
 <5685A273.6070607@users.sourceforge.net>
 <20160107110701.GE25086@rric.localdomain>
 <568EBCE7.4060502@users.sourceforge.net>
 <1452195846.4028.24.camel@perches.com>
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
In-Reply-To: <1452195846.4028.24.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> Is it a bit more efficient to avoid a double check for the
>> variable "ret" at the end of the current implementation for the
>> discussed function?
> 
> Before asking questions you could answer yourself,
> please look at object code produced by the compiler
> before and after your proposed changes.

* Do any more source code reviewers wonder about the need
  for such a double check?

* Which object code representations would you find representative
  for a further constructive discussion around this
  software component?

Regards,
Markus
