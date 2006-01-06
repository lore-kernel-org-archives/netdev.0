From: Lee Revell <rlrevell@joe-job.com>
Subject: Re: [PATCH, RFC] RCU : OOM avoidance and lower latency
Date: Fri, 06 Jan 2006 14:26:39 -0500
Message-ID: <1136575600.17979.58.camel@mindpipe>
References: <20060105235845.967478000@sorel.sous-sol.org>
	 <Pine.LNX.4.64.0601051727070.3169@g5.osdl.org>
	 <43BE43B6.3010105@cosmosbay.com>  <200601061358.42344.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Linus Torvalds <torvalds@osdl.org>,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Dipankar Sarma <dipankar@in.ibm.com>,
	"Paul E. McKenney" <paulmck@us.ibm.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964846AbWAFT0o@vger.kernel.org>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <200601061358.42344.ak@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-01-06 at 13:58 +0100, Andi Kleen wrote:
> Another CPU might be stuck in a long 
> running interrupt

Shouldn't a long running interrupt be considered a bug?

Lee
