From: =?UTF-8?B?SsOpcsOpbXk=?= Lefaure <jeremy.lefaure@lse.epita.fr>
Subject: Re: [PATCH 05/18] net: use ARRAY_SIZE
Date: Mon, 2 Oct 2017 21:23:06 -0400
Message-ID: <20171002212306.29ca6488@blatinox-laptop.localdomain>
References: <20171001193101.8898-1-jeremy.lefaure@lse.epita.fr>
        <20171001193101.8898-6-jeremy.lefaure@lse.epita.fr>
        <87h8vh64sq.fsf@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: Sathya Perla <sathya.perla@broadcom.com>,
        Ajit Khaparde <ajit.khaparde@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Chi-Hsien Lin <chi-hsien.lin@cypress.com>,
        Wright Feng <wright.feng@cypress.com>,
        Larry Finger <Larry.Finger@lwfinger.net>,
        Chaoming Li <chaoming_li@realsil.com.cn>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        intel-wired-lan@lists.osuosl.org, linux-usb@vger.kerne
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from blatinox.fr ([51.254.120.209]:41830 "EHLO vps202351.ovh.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751421AbdJCBij (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 21:38:39 -0400
In-Reply-To: <87h8vh64sq.fsf@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 02 Oct 2017 16:46:29 +0300
Kalle Valo <kvalo@codeaurora.org> wrote:

> We have a tree for wireless so usually it's better to submit wireless
> changes on their own but here I assume Dave will apply this to his tree.
> If not, please resubmit the wireless part in a separate patch.
Ok, I note that.

I'll wait Dave's answer and I'll split this patch if needed.

Thank you,
Jérémy
