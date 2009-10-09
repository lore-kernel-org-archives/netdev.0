From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][v2] ibm_newemac: Added 16K Tx FIFO size support for EMAC4
Date: Thu, 08 Oct 2009 22:55:38 -0700 (PDT)
Message-ID: <20091008.225538.130921151.davem@davemloft.net>
References: <1255019541-1974-1-git-send-email-dmitchell@appliedmicro.com>
	<1255054502.2355.27.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	dmitchell@appliedmicro.com
To: benh@kernel.crashing.org
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1255054502.2355.27.camel@pasglop>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Fri, 09 Oct 2009 13:15:02 +1100

> On Thu, 2009-10-08 at 11:32 -0500, Dave Mitchell wrote:
>> Some of the EMAC V4 implementations support 16K Tx FIFOs. This
>> patch adds support for this functionality and fixes typos in the
>> Tx FIFO size error messages.
> 
> Acked-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> ---
> 
>> Signed-off-by: Dave Mitchell <dmitchell@appliedmicro.com>
>> Acked-by: Prodyut Hazarika <phazarika@appliedmicro.com>
>> Acked-by: Victor Gallardo <vgallardo@appliedmicro.com>
>> Acked-by: Loc Ho <lho@appliedmicro.com>

Applied to net-2.6, thanks!
