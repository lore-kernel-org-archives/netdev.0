From: Roland Dreier <rolandd@cisco.com>
Subject: Re: [PATCH] netdevice.h: Add RDMA private pointer
	to the net_device structure
Date: Mon, 03 Oct 2005 14:29:08 -0700
Message-ID: <52fyri9tnf.fsf@cisco.com>
References: <1128365323.4397.38.camel@hal.voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Hal Rosenstock <halr@voltaire.com>
In-Reply-To: <1128365323.4397.38.camel@hal.voltaire.com> (Hal Rosenstock's
	message of "03 Oct 2005 14:48:44 -0400")
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

    Hal> netdevice.h: Add RDMA private pointer to the net_device structure

I don't think there's any point in making this change until we have
some code that will use the pointer.

 - R.
