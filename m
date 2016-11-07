From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: [PATCH net-next v6 02/10] dpaa_eth: add support for DPAA Ethernet
Date: Mon, 7 Nov 2016 16:25:56 +0000
Message-ID: <1478535955.1983.118.camel@transmode.se>
References: <1478117854-8952-1-git-send-email-madalin.bucur@nxp.com>
         <1478117854-8952-3-git-send-email-madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-15"
Content-Transfer-Encoding: 8BIT
Cc: "joe@perches.com" <joe@perches.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "oss@buserror.net" <oss@buserror.net>,
        "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
        "pebolle@tiscali.nl" <pebolle@tiscali.nl>,
        "ppc@mindchasers.com" <ppc@mindchasers.com>,
        "davem@davemloft.net" <davem@davemloft.net>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "madalin.bucur@nxp.com" <madalin.bucur@nxp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478117854-8952-3-git-send-email-madalin.bucur@nxp.com>
Content-Language: en-US
Content-ID: <BA97FA0564313D4EAFECDAFC9020926C@transmode.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-11-02 at 22:17 +0200, Madalin Bucur wrote:
> This introduces the Freescale Data Path Acceleration Architecture
> (DPAA) Ethernet driver (dpaa_eth) that builds upon the DPAA QMan,
> BMan, PAMU and FMan drivers to deliver Ethernet connectivity on
> the Freescale DPAA QorIQ platforms.

Nice to see DPAA support soon entering the kernel(not a day too early:)
I would like to see BQL supported from day one though, if possible.

 Regards
          Joakim Tjernlund
