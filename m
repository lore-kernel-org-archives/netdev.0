From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] openvswitch: fix mis-ordered comment lines
 for ovs_skb_cb
Date: Mon, 03 Jul 2017 05:54:13 -0700 (PDT)
Message-ID: <20170703.055413.2273392695252860897.davem@davemloft.net>
References: <20170703114643.3441-1-dja@axtens.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: dja-Yfaxwxk/+vWsTnJN9+BGXg@public.gmane.org
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20170703114643.3441-1-dja-Yfaxwxk/+vWsTnJN9+BGXg@public.gmane.org>
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Daniel Axtens <dja-Yfaxwxk/+vWsTnJN9+BGXg@public.gmane.org>
Date: Mon,  3 Jul 2017 21:46:43 +1000

> I was trying to wrap my head around meaning of mru, and realised
> that the second line of the comment defining it had somehow
> ended up after the line defining cutlen, leading to much confusion.
> 
> Reorder the lines to make sense.
> 
> Signed-off-by: Daniel Axtens <dja-Yfaxwxk/+vWsTnJN9+BGXg@public.gmane.org>

Applied, thanks.
