From: Balazs Scheidler <bazsi@balabit.hu>
Subject: Re: [PATCH] [TPROXY] implemented IP_RECVORIGDSTADDR socket option
Date: Fri, 14 Nov 2008 13:41:06 +0100
Message-ID: <1226666466.7446.95.camel@bzorp.balabit>
References: <OFC7049353.2A81DAC6-ON88257500.006FC596-88257500.006FDC40@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrey Luzgin <andrey@icomsw.com>, davem@davemloft.net,
	KOVACS Krisztian <hidden@sch.bme.hu>,
	Jan Engelhardt <jengelh@medozas.de>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, netfilter-devel@vger.kernel.org,
	tproxy@lists.balabit.hu
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <OFC7049353.2A81DAC6-ON88257500.006FC596-88257500.006FDC40@us.ibm.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2008-11-13 at 12:21 -0800, David Stevens wrote:
> I know it's not part of your patch, but what about turning that into
> an array of function pointers and a loop, as code cleanup?
> 
>                                         +-DLS
> 
> 

I could do that if I get a positive feedback from DaveM, that the
sockopt itself is ok. (functionally it was already tested independently
from me)

-- 
Bazsi


