From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ravb: fix RX queue #1 frame error counter name
Date: Sat, 05 Dec 2015 17:46:55 -0500 (EST)
Message-ID: <20151205.174655.363763973003627210.davem@davemloft.net>
References: <2605754.h5jel2JHUq@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <2605754.h5jel2JHUq@wasted.cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Fri, 04 Dec 2015 01:51:10 +0300

> The Rx queue #1 frame error counter name contains trailing underscore,
> probably due to a typo...
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied.
