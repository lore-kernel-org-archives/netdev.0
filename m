From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] netfilter/ipt_tcpmss.c: remove an unused function
Date: Mon, 1 Nov 2004 16:31:00 -0800
Message-ID: <20041101163100.60e737ff.davem@davemloft.net>
References: <20041028230202.GV3207@stusta.de>
	<20041029002113.GP29142@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, coreteam@netfilter.org,
	netfilter-devel@lists.netfilter.org,
	linux-kernel@vger.kernel.org, marc@mbsi.ca
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20041029002113.GP29142@stusta.de>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Fri, 29 Oct 2004 02:21:13 +0200
Adrian Bunk <bunk@stusta.de> wrote:

> The patch below removes an unused function from 
> net/ipv4/netfilter/ipt_tcpmss.c

Applied, thanks Adrian.  This one is probably due to cut&paste
from ipt_TCPMSS.c where this inline is also implemented and also
actually used :-)
