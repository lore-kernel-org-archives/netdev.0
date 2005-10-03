From: Roland Dreier <rolandd@cisco.com>
Subject: Re: [PATCH] netdevice.h: Add RDMA private pointer
	to the net_device structure
Date: Mon, 03 Oct 2005 15:17:18 -0700
Message-ID: <52psqm8cup.fsf@cisco.com>
References: <1128365323.4397.38.camel@hal.voltaire.com>
	<52fyri9tnf.fsf@cisco.com>
	<1128374816.4397.343.camel@hal.voltaire.com>
	<523bni9tck.fsf@cisco.com>
	<1128375898.4397.389.camel@hal.voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Hal Rosenstock <halr@voltaire.com>
In-Reply-To: <1128375898.4397.389.camel@hal.voltaire.com> (Hal Rosenstock's
	message of "03 Oct 2005 17:50:21 -0400")
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

    Hal> I wanted to get this in so I could add the code to IPoIB to
    Hal> use this so SDP and others no longer poke at IPoIB's private
    Hal> data. This is a small change. Should this change be made
    Hal> locally (in OpenIB) first (and we'll have our own modified
    Hal> netdevice.h for a short time) ?

Yes, I think that's the way to develop this sort of thing.

 - R.
