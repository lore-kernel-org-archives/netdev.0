From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix security_socket_sendmsg() bypass problem.
Date: Tue, 02 Aug 2011 20:38:36 -0700 (PDT)
Message-ID: <20110802.203836.40056483416201909.davem@davemloft.net>
References: <20110802.050115.1714327089688495866.davem@davemloft.net>
	<201108022211.BJI69291.QLFFJMOOtOHVSF@I-love.SAKURA.ne.jp>
	<201108030325.p733Pplb030986@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, eparis@parisplace.org, casey@schaufler-ca.com,
	mjt@tls.msk.ru, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: penguin-kernel@I-love.SAKURA.ne.jp
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201108030325.p733Pplb030986@www262.sakura.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Wed, 03 Aug 2011 12:25:51 +0900

> Tetsuo Handa wrote:
>> I see. Here is an updated version.
> Oops, seems whitespace damaged. Resending.
> 
> Also, attaching kmalloc()-free version. If performance loss by kmalloc()-free
> version is small enough, can it be a candidate?

Anton, _PLEASE_ look into this and do some testing or at least give
some kind of feedback.

This regression came from your change so I really need you to be
active in the resolution of this regression.

Thanks.
