From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v4 0/4] fsl/fman: fixes for ARM
Date: Tue, 20 Dec 2016 14:00:53 -0500 (EST)
Message-ID: <20161220.140053.624816790746806575.davem@davemloft.net>
References: <1482180166-10677-1-git-send-email-madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-kernel@vger.kernel.org, scott.wood@nxp.com
To: madalin.bucur@nxp.com
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1482180166-10677-1-git-send-email-madalin.bucur@nxp.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

From: Madalin Bucur <madalin.bucur@nxp.com>
Date: Mon, 19 Dec 2016 22:42:42 +0200

> The patch set fixes advertised speeds for QSGMII interfaces, disables
> A007273 erratum workaround on non-PowerPC platforms where it does not
> apply, enables compilation on ARM64 and addresses a probing issue on
> non PPC platforms.
> 
> Changes from v3: removed redundant comment, added ack by Scott
> Changes from v2: merged fsl/fman changes to avoid a point of failure
> Changes from v1: unifying probing on all supported platforms

Series applied, thanks.
