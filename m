From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH] [POWERPC] Add fixed-phy support for fs_enet
Date: Wed, 23 Jan 2008 19:51:25 -0600 (CST)
Message-ID: <Pine.LNX.4.64.0801231951150.8658@blarg.am.freescale.net>
References: <4767E677.7010200@scram.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Kernel, Linux" <linux-kernel@vger.kernel.org>, linuxppc-dev@ozlabs.org,
	Paul Mackerras <paulus@samba.org>, netdev@vger.kernel.org,
	Scott Wood <scottwood@freescale.com>, "Garzik, Jeff" <jgarzik@pobox.com>
To: Jochen Friedrich <jochen@scram.de>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <4767E677.7010200@scram.de>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Tue, 18 Dec 2007, Jochen Friedrich wrote:

> This patch adds support to use the fixed-link property
> of an ethernet node to fs_enet for the
> CONFIG_PPC_CPM_NEW_BINDING case.
>
> Signed-off-by: Jochen Friedrich <jochen@scram.de>
> Acked-by: Jeff Garzik <jeff@garzik.org>
> Acked-by: Vitali Bordug <vitb@kernel.crashing.org>
> ---
>  drivers/net/fs_enet/fs_enet-main.c |    9 ++++++++-
>  1 files changed, 8 insertions(+), 1 deletions(-)
>

applied.

- k
