From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cosa: use msecs_to_jiffies for conversions
Date: Sun, 07 Jun 2015 23:46:10 -0700 (PDT)
Message-ID: <20150607.234610.2272133610437671044.davem@davemloft.net>
References: <1433577111-7404-1-git-send-email-hofrat@osadl.org>
	<20150607.001800.854104281240414676.davem@davemloft.net>
	<20150607082558.GA9670@opentech.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hofrat@osadl.org, kas@fi.muni.cz, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: der.herr@hofr.at
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150607082558.GA9670@opentech.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicholas Mc Guire <der.herr@hofr.at>
Date: Sun, 7 Jun 2015 10:25:58 +0200

> for the dscc4 case Im not sure - that seems to have gone in in 2.4
> and that had HZ configurable. The cosa case was checked 
> again 2.2.26 (no config HZ) and the timeout there was 30 -> 300ms.
> 
> I think that this is consistent with respect to the limited available
> information of the timeout unit in the code.

Ok, applied.
