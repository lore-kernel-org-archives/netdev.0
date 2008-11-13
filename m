From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] [TPROXY] implemented IP_RECVORIGDSTADDR socket option
Date: Thu, 13 Nov 2008 12:21:49 -0800
Message-ID: <OFC7049353.2A81DAC6-ON88257500.006FC596-88257500.006FDC40@us.ibm.com>
References: <1226572624.7164.11.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Andrey Luzgin <andrey@icomsw.com>, davem@davemloft.net,
	KOVACS Krisztian <hidden@sch.bme.hu>,
	Jan Engelhardt <jengelh@medozas.de>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, netfilter-devel@vger.kernel.org,
	tproxy@lists.balabit.hu
To: Balazs Scheidler <bazsi@balabit.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1226572624.7164.11.camel@bzorp.balabit>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I know it's not part of your patch, but what about turning that into
an array of function pointers and a loop, as code cleanup?

                                        +-DLS

