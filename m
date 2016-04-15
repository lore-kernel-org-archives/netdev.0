From: David Miller <davem@davemloft.net>
Subject: Re: Deleting child qdisc doesn't reset parent to default qdisc?
Date: Fri, 15 Apr 2016 13:13:17 -0400 (EDT)
Message-ID: <20160415.131317.937825031149120252.davem@davemloft.net>
References: <1460656170.10638.61.camel@edumazet-glaptop3.roam.corp.google.com>
	<5710E1C1.2090209@mojatatu.com>
	<1460732328.10638.74.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, jikos@kernel.org, phil@nwl.cc,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460732328.10638.74.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 15 Apr 2016 07:58:48 -0700

> Having some hidden qdiscs is the real problem here.

+1
