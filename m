From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH] LSM: Update comment on security_sock_rcv_skb
Date: Mon, 11 Jan 2010 08:53:55 +1100 (EST)
Message-ID: <alpine.LRH.2.00.1001110853420.25601@tundra.namei.org>
References: <1262437456-24476-1-git-send-email-sam@synack.fr> <1262537872.10218.27.camel@bigi> <m2r5q5nhbc.fsf@ssh.synack.fr> <201001050820.o058Kuwx087793@www262.sakura.ne.jp> <20100105140917.GA6624@us.ibm.com>
 <201001060023.o060Ns76078068@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-security-module@vger.kernel.org, serue@us.ibm.com,
	sam@synack.fr, kaber@trash.net, zbr@ioremap.net,
	nhorman@tuxdriver.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, hadi@cyberus.ca
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201001060023.o060Ns76078068@www262.sakura.ne.jp>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 6 Jan 2010, Tetsuo Handa wrote:

> [PATCH] LSM: Update comment on security_sock_rcv_skb
> 
> It is not permitted to do sleeping operation inside security_sock_rcv_skb().
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>


Applied to
git://git.kernel.org/pub/scm/linux/kernel/git/jmorris/security-testing-2.6#next


-- 
James Morris
<jmorris@namei.org>
