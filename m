From: David Miller <davem@davemloft.net>
Subject: Re: Please pull - generic HDLC
Date: Sun, 12 Oct 2008 14:47:04 -0700 (PDT)
Message-ID: <20081012.144704.39192150.davem@davemloft.net>
References: <m33aj15xhr.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: khc@pm.waw.pl
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755096AbYJLVrl@vger.kernel.org>
In-Reply-To: <m33aj15xhr.fsf@maximus.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Krzysztof Halasa <khc@pm.waw.pl>
Date: Sun, 12 Oct 2008 23:12:16 +0200

> David,
> 
> The following changes since commit
> f3073ac76755abd63b1d4c3d145f4c15b65b5355 (i.e., your netdev-2.6):
> Guennadi Liakhovetski (1): smc911x: Fix external PHY detection
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/chris/linux-2.6.git for-david

You've missed the networking merge window, as I stated the other
day I'm not taking any more networking changes.

You should have merged this in earlier.

--------------------
Subject: preparing net-next-2.6 for merge...
From: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
CC: linux-wireless@vger.kernel.org
Date: Fri, 10 Oct 2008 12:29:37 -0700 (PDT)
X-Mailer: Mew version 6.1 on Emacs 22.1 / Mule 5.0 (SAKAKI)


I'm doing some quick merge, build, and boot tests on the tree as it
stands right now then I'll send a pull request to Linus.

I'm sure there are some things people still wanted to get into the
tree, but let's try to follow the rules this time.  Only bug fixes
and corrections at this point forward.

Look at it this way, I have tons of stuff I wasn't able to finish up
in time either, so both the rule and the pain and being applied fairly
:-)

Anyways, just FYI...
