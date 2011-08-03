From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH] net: Fix security_socket_sendmsg() bypass problem.
Date: Wed, 3 Aug 2011 23:54:13 +1000
Message-ID: <20110803235413.6d1a589d@kryten>
References: <20110802.041857.1325765319466840715.davem@davemloft.net>
	<20110802.042641.2122529993066553943.davem@davemloft.net>
	<201108022052.FBE56208.FLQHFtMOVOSOJF@I-love.SAKURA.ne.jp>
	<20110802.050115.1714327089688495866.davem@davemloft.net>
	<201108022211.BJI69291.QLFFJMOOtOHVSF@I-love.SAKURA.ne.jp>
	<201108030325.p733Pplb030986@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eparis@parisplace.org, casey@schaufler-ca.com,
	mjt@tls.msk.ru, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201108030325.p733Pplb030986@www262.sakura.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> Also, attaching kmalloc()-free version. If performance loss by
> kmalloc()-free version is small enough, can it be a candidate?

Thanks. Running some benchmarks across both versions, will have some
numbers later on today.

Anton
