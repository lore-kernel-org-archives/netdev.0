From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPVS: Remove supports_ipv6 scheduler flag
Date: Mon, 03 Nov 2008 17:09:13 -0800 (PST)
Message-ID: <20081103.170913.161467814.davem@davemloft.net>
References: <20081104005826.GA28967@cydonia.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
	horms@verge.net.au
To: julius.volz@gmail.com
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20081104005826.GA28967@cydonia.lan>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julius Volz <julius.volz@gmail.com>
Date: Tue, 4 Nov 2008 01:58:26 +0100

> Remove the 'supports_ipv6' scheduler flag since all schedulers now
> support IPv6.
> 
> Signed-off-by: Julius Volz <julius.volz@gmail.com>

Since Simon explicitly asked for this patch, I've applied
it :-)
