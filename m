From: Hal Rosenstock <halr@voltaire.com>
Subject: Re: [PATCH] netdevice.h: Add RDMA private pointer
	to the net_device structure
Date: 03 Oct 2005 16:53:52 -0400
Message-ID: <1128372832.4397.270.camel@hal.voltaire.com>
References: <1128365323.4397.38.camel@hal.voltaire.com>
	<20051003135407.072aaff6@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20051003135407.072aaff6@dxpl.pdx.osdl.net>
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

On Mon, 2005-10-03 at 16:54, Stephen Hemminger wrote:
> On 03 Oct 2005 14:48:44 -0400
> Hal Rosenstock <halr@voltaire.com> wrote:
> 
> > netdevice.h: Add RDMA private pointer to the net_device structure
> > 
> > Signed-off-by: Hal Rosenstock <halr@voltaire.com>
> 
> Who is going to use it? Is RDMA being submitted for code review?

IB (and ultimately RDMA) will use it.

-- Hal
