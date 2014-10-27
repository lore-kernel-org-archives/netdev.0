From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 1/1 net-next] xfrm: fix set but not used warning in
 xfrm_policy_queue_process()
Date: Mon, 27 Oct 2014 14:35:10 +0100
Message-ID: <20141027133510.GA25142@secunet.com>
References: <1414250829-17908-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-kernel@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Fabian Frederick <fabf@skynet.be>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1414250829-17908-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 25, 2014 at 05:27:09PM +0200, Fabian Frederick wrote:
> err was set but unused.
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Applied to ipsec-next, thanks!
