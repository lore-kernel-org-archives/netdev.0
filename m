From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch 2/3] sysctl: add proc_do_large_bitmap
Date: Wed, 05 May 2010 11:14:04 +0800
Message-ID: <4BE0E27C.7040200@redhat.com>
References: <20100430082912.5630.82405.sendpatchset@localhost.localdomain> 	<20100430082936.5630.67682.sendpatchset@localhost.localdomain> <v2y412e6f7f1004301541yb1ede589t8c446966743ca138@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Octavian Purdila <opurdila@ixiacom.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	penguin-kernel@i-love.sakura.ne.jp, netdev@vger.kernel.org,
	Neil Horman <nhorman@tuxdriver.com>, ebiederm@xmission.com,
	adobriyan@gmail.com, David Miller <davem@davemloft.net>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <v2y412e6f7f1004301541yb1ede589t8c446966743ca138@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Changli Gao wrote:
>                      add the following lines to let "echo 1-10 >>
> /proc/..." work as normal.

Hmm, I haven't tested this, what did you see if we append
lines into it?

Also, do we need appending lines to this /proc file when design it?
Octavian? Eric?

Thanks.
