From: Stanislav Yakovlev <stas.yakovlev@gmail.com>
Subject: Re: [RESEND][PATCH 3/7] net, ipw2x00: remove redundant D0 power state set
Date: Tue, 4 Jun 2013 02:16:34 -0700
Message-ID: <CA++WF2M0eW2ErthByhDjk1tEacgfo-Fw2pHP_UL4Be2fLDdmoQ@mail.gmail.com>
References: <1370329674-8360-1-git-send-email-wangyijing@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org
To: Yijing Wang <wangyijing@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f177.google.com ([209.85.220.177]:43981 "EHLO
	mail-vc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751503Ab3FDJQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 05:16:35 -0400
In-Reply-To: <1370329674-8360-1-git-send-email-wangyijing@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Yijing,

On 4 June 2013 00:07, Yijing Wang <wangyijing@huawei.com> wrote:
> Pci_enable_device() will set device power state to D0,
> so it's no need to do it again in ipw2100_pci_init_one().
>
> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
> Cc: Stanislav Yakovlev <stas.yakovlev@gmail.com>
> Cc: "John W. Linville" <linville@tuxdriver.com>
> Cc: netdev@vger.kernel.org
> Cc: linux-wireless@vger.kernel.org

Looks fine, thanks.

Stanislav.
