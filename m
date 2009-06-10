From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/5] can: af_can.c use rcu_barrier() on module unload.
Date: Wed, 10 Jun 2009 01:52:45 -0700 (PDT)
Message-ID: <20090610.015245.141342130.davem@davemloft.net>
References: <4A2D112A.4000308@hartkopp.net>
	<20090610.011027.43904351.davem@davemloft.net>
	<4A2F6D32.8030400@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: patchwork@ozlabs.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: oliver@hartkopp.net
Return-path: <patchwork-bounces+gcvp-patchwork=m.gmane.org@ozlabs.org>
In-Reply-To: <4A2F6D32.8030400@hartkopp.net>
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

From: Oliver Hartkopp <oliver@hartkopp.net>
Date: Wed, 10 Jun 2009 10:22:10 +0200

> David Miller wrote:
>> Otherwise
>> patchwork doesn't pick them up automatically.
> 
> IMHO patchwork should be robust against these type of typos and convert them
> for the users (== your) convenience into 'Acked-by:' ...

We really can't expect patchwork to look for every conceivable
malignment of the various reviewer tags.
