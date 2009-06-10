From: Jeremy Kerr <jk@ozlabs.org>
Subject: Re: [PATCH 3/5] can: af_can.c use rcu_barrier() on module unload.
Date: Wed, 10 Jun 2009 22:41:47 +1000
Message-ID: <200906102241.47823.jk@ozlabs.org>
References: <4A2D112A.4000308@hartkopp.net> <4A2F6D32.8030400@hartkopp.net>
	<20090610.015245.141342130.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org, oliver@hartkopp.net,
	David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org
To: patchwork@ozlabs.org
Return-path: <patchwork-bounces+gcvp-patchwork=m.gmane.org@ozlabs.org>
In-Reply-To: <20090610.015245.141342130.davem@davemloft.net>
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/options/patchwork>,
	<mailto:patchwork-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/patchwork>
List-Post: <mailto:patchwork@ozlabs.org>
List-Help: <mailto:patchwork-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/patchwork>,
	<mailto:patchwork-request@ozlabs.org?subject=subscribe>
Sender: patchwork-bounces+gcvp-patchwork=m.gmane.org@ozlabs.org
Errors-To: patchwork-bounces+gcvp-patchwork=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

David,

> We really can't expect patchwork to look for every conceivable
> malignment of the various reviewer tags.

No, but we could probably be more tolerant about capitalisation. Any 
objections about ignoring case completely? I have a patch ready to 
push...

Cheers,


Jeremy
