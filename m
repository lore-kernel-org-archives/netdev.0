From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] netdevice.h: Add RDMA private pointer
	to the net_device structure
Date: Mon, 03 Oct 2005 14:34:07 -0700 (PDT)
Message-ID: <20051003.143407.49100316.davem@davemloft.net>
References: <1128365323.4397.38.camel@hal.voltaire.com>
	<52fyri9tnf.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: openib-general@openib.org, netdev@vger.kernel.org
Return-path: <openib-general-bounces@openib.org>
To: rolandd@cisco.com
In-Reply-To: <52fyri9tnf.fsf@cisco.com>
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

From: Roland Dreier <rolandd@cisco.com>
Date: Mon, 03 Oct 2005 14:29:08 -0700

>     Hal> netdevice.h: Add RDMA private pointer to the net_device structure
> 
> I don't think there's any point in making this change until we have
> some code that will use the pointer.

I definitely agree.
