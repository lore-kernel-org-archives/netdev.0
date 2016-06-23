From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: vrf: replace hard tab with space in assignment
Date: Thu, 23 Jun 2016 15:20:37 -0400 (EDT)
Message-ID: <20160623.152037.1185109841504362333.davem@davemloft.net>
References: <20160621033943.21947-1-chris.packham@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	shm@cumulusnetworks.com, dsa@cumulusnetworks.com
To: chris.packham@alliedtelesis.co.nz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160621033943.21947-1-chris.packham@alliedtelesis.co.nz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Packham <chris.packham@alliedtelesis.co.nz>
Date: Tue, 21 Jun 2016 15:39:43 +1200

> The assignment of rth->dst.output in vrf_rt6_create() and
> vrf_rtable_create() used a hard tab before the '='. The neighboring
> assignments did not. Make the assignment of rth->dst.output consistent
> with the surrounding code.
> 
> Signed-off-by: Chris Packham <chris.packham@alliedtelesis.co.nz>

Applied.
