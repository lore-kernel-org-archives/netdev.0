From: Hal Rosenstock <halr@voltaire.com>
Subject: Re: [PATCH] netdevice.h: Add RDMA private pointer
	to the net_device structure
Date: 03 Oct 2005 17:26:56 -0400
Message-ID: <1128374816.4397.343.camel@hal.voltaire.com>
References: <1128365323.4397.38.camel@hal.voltaire.com>
	<52fyri9tnf.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Roland Dreier <rolandd@cisco.com>
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

On Mon, 2005-10-03 at 17:29, Roland Dreier wrote:
>     Hal> netdevice.h: Add RDMA private pointer to the net_device structure
> 
> I don't think there's any point in making this change until we have
> some code that will use the pointer.

We will have this shortly. I have been waiting for this to propose the
changes to SDP et al.

-- Hal
