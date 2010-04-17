From: Finn Thain <fthain@telegraphics.com.au>
Subject: Re: [PATCH] mac8390: fix pr_info() calls and change return code
Date: Sat, 17 Apr 2010 12:28:32 +1000 (EST)
Message-ID: <alpine.OSX.2.00.1004171107060.340@localhost>
References: <alpine.OSX.2.00.1004161214270.271@localhost>  <20100415.200113.215578006.davem@davemloft.net>  <alpine.OSX.2.00.1004161323340.271@localhost>  <alpine.OSX.2.00.1004161403160.271@localhost> <1271392454.2298.37.camel@Joe-Laptop.home>
 <alpine.OSX.2.00.1004162340370.271@localhost> <20100416.132855.230883346.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Joe Perches <joe@perches.com>, p_gortmaker@yahoo.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-m68k@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100416.132855.230883346.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Fri, 16 Apr 2010, David Miller wrote:

> 
> I just want to point out that with all the trouble you gave about Joe's 
> work, you're having one heck of a time even submitting your changes 
> properly. :-)

You are a thorough reviewer, despite the regrettable implication to the 
contrary in my first message in this thread. And you are quite right, I 
did not understand the pr_* macros at the time. I apologise.

I am hypersensitive to bit rot. I guess that's what happens when one makes 
it one's job to fix regressions in Linux.

Finn
