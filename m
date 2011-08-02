From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix security_socket_sendmsg() bypass problem.
Date: Mon, 01 Aug 2011 23:07:31 -0700 (PDT)
Message-ID: <20110801.230731.1942061135621106602.davem@davemloft.net>
References: <201107262021.FCC34304.HMOOFQJVSFLFOt@I-love.SAKURA.ne.jp>
	<CACLa4pvJ2+eTRf3SRzoXgiW8H+U=BDH-2DKVZ7pGRrPem=JYgg@mail.gmail.com>
	<201107280336.p6S3aUY7004372@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eparis@parisplace.org, anton@samba.org, casey@schaufler-ca.com,
	mjt@tls.msk.ru, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: penguin-kernel@i-love.sakura.ne.jp
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201107280336.p6S3aUY7004372@www262.sakura.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Date: Thu, 28 Jul 2011 12:36:30 +0900

> Here is an optimized version. Only compile tested.

Anton, please test this or I'm just going to apply it before it
gets any testing :-)
