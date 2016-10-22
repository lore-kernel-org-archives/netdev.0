From: Joel Stanley <joel@jms.id.au>
Subject: Re: [PATCH 1/2] net: phy: broadcom: Update Auxiliary Control Register macros
Date: Sat, 22 Oct 2016 11:11:20 +1030
Message-ID: <CACPK8XekEYGA95+u=+XUVgLBNwU1z6gSSqbNNOwyqgTBOtZScA@mail.gmail.com>
References: <1477070413-92621-1-git-send-email-xow@google.com> <1477070413-92621-2-git-send-email-xow@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Fainelli <f.fainelli@gmail.com>, davem@davemloft.net,
        jaedon.shin@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        OpenBMC Maillist <openbmc@lists.ozlabs.org>
To: Xo Wang <xow@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33424 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755410AbcJVAll (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 20:41:41 -0400
In-Reply-To: <1477070413-92621-2-git-send-email-xow@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 22, 2016 at 3:50 AM, Xo Wang <xow@google.com> wrote:
> Add the RXD-to-RXC skew (delay) time bit in the Miscellaneous Control
> shadow register and a mask for the shadow selector field.
>
> Remove a re-definition of MII_BCM54XX_AUXCTL_SHDWSEL_AUXCTL.
>
> Signed-off-by: Xo Wang <xow@google.com>

Reviewed-by: Joel Stanley <joel@jms.id.au>

Cheers,

Joel

> ---
>  include/linux/brcmphy.h | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
