From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2] openvswitch: Fix an error handling path in
 'ovs_nla_init_match_and_action()'
Date: Tue, 12 Sep 2017 20:38:54 -0700 (PDT)
Message-ID: <20170912.203854.934620252544016023.davem@davemloft.net>
References: <20170911195620.17931-1-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: christophe.jaillet-39ZsbGIQGT5GWvitb5QawA@public.gmane.org
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20170911195620.17931-1-christophe.jaillet-39ZsbGIQGT5GWvitb5QawA@public.gmane.org>
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

From: Christophe JAILLET <christophe.jaillet-39ZsbGIQGT5GWvitb5QawA@public.gmane.org>
Date: Mon, 11 Sep 2017 21:56:20 +0200

> All other error handling paths in this function go through the 'error'
> label. This one should do the same.
> 
> Fixes: 9cc9a5cb176c ("datapath: Avoid using stack larger than 1024.")
> Signed-off-by: Christophe JAILLET <christophe.jaillet-39ZsbGIQGT5GWvitb5QawA@public.gmane.org>

Applied.
