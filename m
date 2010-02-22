From: Anatolij Gustschin <agust@denx.de>
Subject: Re: [net-next-2.6 PATCH v2 0/3] Support for MPC512x FEC
Date: Mon, 22 Feb 2010 12:37:24 +0100
Message-ID: <20100222123724.67a7b862@wker>
References: <1266418530-2727-1-git-send-email-agust@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Wolfgang Denk <wd@denx.de>, Detlev Zundel <dzu@denx.de>,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1266418530-2727-1-git-send-email-agust@denx.de>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

Hi David,

On Wed, 17 Feb 2010 15:55:27 +0100
Anatolij Gustschin <agust@denx.de> wrote:

> These patches attempt to provide support for the Freescale MPC512x
> FEC in the fs_enet driver. The first cleanup patch replaces printk
> by dev_xxx. The second and third attemt to support MPC5121 FEC
> in the FEC driver.

Could you please comment on this patch series. The patches
have been acked by Grant and I slightly reworked third patch
to address Eric's comments, so there is v3 for this patch now.

Thanks,

Anatolij
