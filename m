From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch] net_sched: info leak in atm_tc_dump_class()
Date: Tue, 30 Jul 2013 13:18:20 +0200
Message-ID: <20130730111820.GA1646@minipsycho.brq.redhat.com>
References: <20130730102339.GA14869@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130730102339.GA14869@elgon.mountain>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tue, Jul 30, 2013 at 12:23:39PM CEST, dan.carpenter@oracle.com wrote:
>The "pvc" struct has a hole after pvc.sap_family which is not cleared.
>
>Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
Reviewed-by: Jiri Pirko <jiri@resnulli.us>
