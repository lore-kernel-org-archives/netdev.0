From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net RESEND 0/2] overflow-arith: begin to add support
 for overflow builtins functions
Date: Fri, 23 Oct 2015 02:50:05 -0700 (PDT)
Message-ID: <20151023.025005.1155789583520008596.davem@davemloft.net>
References: <1444987963-15327-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	dvyukov@google.com
To: hannes@stressinduktion.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444987963-15327-1-git-send-email-hannes@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri, 16 Oct 2015 11:32:41 +0200

> I add a new header, linux/overflow-arith.h, as the central place to add
> overflow and wrap-around checking functions. The reason I am doing so
> is that it can make use of compiler supported builtin functions which
> can leverage hardware.
> 
> As I need this for a fix in the ipv6 stack, which is also included in
> this series, I propose to add it sooner than later over Davem's net
> tree. This is also the reason why I start slowly with only the one
> function I need at this time.
> 
> Thanks for reviewing!

Series applied, thanks Hannes.
