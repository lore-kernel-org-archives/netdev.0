From: Stefan Roese <sr@denx.de>
Subject: Re: [PATCH] ibm_newemac: Fix EMACx_TRTR[TRT] bit shifts
Date: Wed, 18 Nov 2009 11:07:51 +0100
Message-ID: <200911181107.51661.sr@denx.de>
References: <1258505815-31261-1-git-send-email-dmitchell@appliedmicro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dave Mitchell <dmitchell@appliedmicro.com>,
	linuxppc-dev@ozlabs.org
To: linuxppc-dev@lists.ozlabs.org
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1258505815-31261-1-git-send-email-dmitchell@appliedmicro.com>
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

On Wednesday 18 November 2009 01:56:55 Dave Mitchell wrote:
> The TRT bit shifts were reversed for EMAC4 and non-EMAC4 during the
> port from ibm_emac to ibm_newemac. This patch corrects that error.
> 
> Signed-off-by: Dave Mitchell <dmitchell@appliedmicro.com>
> Acked-by: Feng Kan <fkan@appliedmicro.com>
> Acked-by: Prodyut Hazarika <phazarika@appliedmicro.com>

Acked-by: Stefan Roese <sr@denx.de>

Would be great if this could go into 2.6.32. Thanks.

Cheers,
Stefan
