From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] icmp: Fixed bug in raw sockets causing incorrect ICMP
 SNMP counter values
Date: Sun, 11 Oct 2015 15:44:03 -0700
Message-ID: <1444603443.27760.147.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151011205528.GA4322@benjojo.co.uk>
	 <1444601448.27760.143.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAL=9YSVgnCDzZkDM4JujD89V3GpUnDGXyMk7qMnWg7LtmT5G7w@mail.gmail.com>
	 <1444603382.27760.146.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ben+patches@benjojo.co.uk,
	David L Stevens <dlstevens@us.ibm.com>
To: Ben Cox <ben@benjojo.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444603382.27760.146.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2015-10-11 at 15:43 -0700, Eric Dumazet wrote:

> But your code reads 21th byte.

BTW, nice catch !

Your patch only need a small addition.

Thanks.
