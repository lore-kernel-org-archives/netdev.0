From: Ed W <lists@wildgooses.com>
Subject: Re: Raise initial congestion window size / speedup slow start?
Date: Thu, 15 Jul 2010 00:05:48 +0100
Message-ID: <4C3E42CC.4010704@wildgooses.com>
References: <4C3E0684.5060409@wildgooses.com> <4C3E1B54.40604@hp.com> <20100714203919.GD6682@nuttenaction> <20100714.145547.102555471.davem@davemloft.net> <20100714221301.GI6682@nuttenaction> <4C3E3F92.2090506@wildgooses.com> <20100714230100.GL6682@nuttenaction>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	davidsen@tmr.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100714230100.GL6682@nuttenaction>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 15/07/2010 00:01, Hagen Paul Pfeifer wrote:
> It is quite late here so I will quickly write two sentence about ECN: one
> month ago Lars Eggers posted a link at the tcpm maillinglist where google (not
> really sure if it was google) analysed the employment of ECN - the usage was
> really low. Search the PDF, it is quite interesting one.
>    

I would speculate that this is because there is a big warning on ECN 
saying that it may cause you to loose customers who can't connect to 
you... Businesses are driven by needing to support the most common case, 
not the most optimal (witness the pain of html development and needing 
to consider IE6...)

What would be more useful is for google to survey how many devices are 
unable to interoperate with ECN and if that number turned out to be 
extremely low, and this fact were advertised, then I suspect we might 
see a mass increase in it's deployment?  I know I have it turned off on 
all my servers because I worry more about loosing one customer than 
improving the experience for all customers...

Cheers

Ed W
