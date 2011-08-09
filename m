From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [Patch] scm: Capture the full credentials of the scm sender
Date: Tue, 09 Aug 2011 11:06:37 -0700
Message-ID: <4E41772D.1070700@linux.intel.com>
References: <1312841316.2576.49.camel@schen9-DESK>	 <1312857834.2531.15.camel@edumazet-laptop> <1312908512.2576.97.camel@schen9-DESK>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>,
	Al Viro <viro@zeniv.linux.org.uk>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Tim Chen <tim.c.chen@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1312908512.2576.97.camel@schen9-DESK>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> This patch corrects an erroneous update of credential's gid with uid
> introduced in commit 257b5358b32f17 since 2.6.36.


Please also add a Cc: stable@kernel.org

-Andi
