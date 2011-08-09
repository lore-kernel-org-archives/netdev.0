From: James Morris <jmorris@namei.org>
Subject: Re: [Patch] scm: Capture the full credentials of the scm sender
Date: Wed, 10 Aug 2011 09:20:58 +1000 (EST)
Message-ID: <alpine.LRH.2.00.1108100920220.2830@tundra.namei.org>
References: <1312841316.2576.49.camel@schen9-DESK>  <1312857834.2531.15.camel@edumazet-laptop> <1312908512.2576.97.camel@schen9-DESK>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>,
	Al Viro <viro@zeniv.linux.org.uk>, ak@linux.intel.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Tim Chen <tim.c.chen@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1312908512.2576.97.camel@schen9-DESK>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 9 Aug 2011, Tim Chen wrote:

> This patch corrects an erroneous update of credential's gid with uid
> introduced in commit 257b5358b32f17 since 2.6.36.
> 
> Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>

Reviewed-by: James Morris <jmorris@namei.org>

-- 
James Morris
<jmorris@namei.org>
