From: Timur Tabi <timur@freescale.com>
Subject: Re: [PATCH 2/2] [POWERPC] UCC nodes cleanup
Date: Fri, 11 Apr 2008 12:08:17 -0500
Message-ID: <47FF9B01.7010207@freescale.com>
References: <20080311171045.GB4684@localhost.localdomain> <82E8E38A-C159-4C23-BDE8-086D4429F366@kernel.crashing.org> <20080411160654.GA25506@polina.dev.rtsoft.ru> <47FF9665.7020403@freescale.com> <20080411170657.GA15270@polina.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Kumar Gala <galak@kernel.crashing.org>, linuxppc-dev@ozlabs.org,
	Jeff Garzik <jgarzik@pobox.com>, linux-serial@vger.kernel.org,
	netdev@vger.kernel.org
To: avorontsov@ru.mvista.com
Return-path: <linux-serial-owner@vger.kernel.org>
In-Reply-To: <20080411170657.GA15270@polina.dev.rtsoft.ru>
Sender: linux-serial-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Anton Vorontsov wrote:

>> Do we want the first UCC to have a cell-index of 1?  Maybe we should fix this
>> off-by-one error once and for all, and number all UCCs from 0?
> 
> Isn't documentation numbers UCC from 1? 

Yes.

> Then I believe we should stick
> with it for device tree, since off by one is Linux implementation details.

Fair enough.

-- 
Timur Tabi
Linux kernel developer at Freescale
