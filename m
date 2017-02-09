From: Li Yang <leoli@freescale.com>
Subject: Re: [PATCH 2/2] soc/fsl/qe: get rid of immrbar_virt_to_phys()
Date: Thu, 9 Feb 2017 17:17:51 -0600
Message-ID: <CADRPPNTTvfcMNkXa-ffNv_-WB=bTP-P7FOfui7nEGV=umw8i=g@mail.gmail.com>
References: <cover.1486456900.git.christophe.leroy@c-s.fr> <804a373374f8ea17d971c4b087fcbe24c0edced7.1486456900.git.christophe.leroy@c-s.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Qiang Zhao <qiang.zhao@nxp.com>, Scott Wood <oss@buserror.net>,
        "David S. Miller" <davem@davemloft.net>,
        lkml <linux-kernel@vger.kernel.org>,
        linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
        Netdev <netdev@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>
To: Christophe Leroy <christophe.leroy@c-s.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f67.google.com ([209.85.213.67]:33534 "EHLO
        mail-vk0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752483AbdBIXRx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 18:17:53 -0500
In-Reply-To: <804a373374f8ea17d971c4b087fcbe24c0edced7.1486456900.git.christophe.leroy@c-s.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 7, 2017 at 3:05 AM, Christophe Leroy
<christophe.leroy@c-s.fr> wrote:
> immrbar_virt_to_phys() is not used anymore
>
> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>

Acked-by: Li Yang <pku.leo@gmail.com>

Regards,
Leo
