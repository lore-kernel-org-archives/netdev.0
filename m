From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/3] via-ircc: fix memory leak
Date: Mon, 25 Sep 2006 22:31:14 -0700 (PDT)
Message-ID: <20060925.223114.52132345.davem@davemloft.net>
References: <200609252343.k8PNh81i002848@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chuck@maggie, bcollins@ubuntu.com,
	samuel@sortiz.org, zulcss@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:49849
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751217AbWIZFbL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Sep 2006 01:31:11 -0400
To: akpm@osdl.org
In-Reply-To: <200609252343.k8PNh81i002848@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@osdl.org
Date: Mon, 25 Sep 2006 16:43:08 -0700

> From: Chuck Short <chuck@maggie>
> 
> Fix memory leak.
> 
> Coverity id# 653
> 
> patch location:
> http://www.kernel.org/git/?p=linux/kernel/git/bcollins/ubuntu-dapper.git;a=commitdiff;h=a1f34cb68b16807ed9d5ebb0f6a6ec5ff8a5fc78
> 
> Signed-off-by: Chuck Short <zulcss@gmail.com>
> Signed-off-by: Ben Collins <bcollins@ubuntu.com>
> Cc: Samuel Ortiz <samuel@sortiz.org>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

Applied, thanks.
