From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCH 2/2] mwifiex: simplify length computation for some memset
Date: Sun, 4 Sep 2016 13:24:47 +1000
Message-ID: <CAGRGNgUP5VmTLzQfT99BqmRO9eKW9Du5e3O7DpdX-rByFSEmEA@mail.gmail.com>
References: <1470641940-26681-1-git-send-email-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Amitkumar Karwar <akarwar@marvell.com>,
        Nishant Sarmukadam <nishants@marvell.com>,
        linux-wireless <linux-wireless@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        kernel-janitors <kernel-janitors@vger.kernel.org>
To: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f49.google.com ([209.85.214.49]:35169 "EHLO
        mail-it0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751524AbcIDDZJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Sep 2016 23:25:09 -0400
In-Reply-To: <1470641940-26681-1-git-send-email-christophe.jaillet@wanadoo.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

On Mon, Aug 8, 2016 at 5:39 PM, Christophe JAILLET
<christophe.jaillet@wanadoo.fr> wrote:
> This patch should be a no-op. It just simplifies code by using the name of
> a variable instead of its type when calling 'sizeof'.
>
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>

Reviewed-by: Julian Calaby <julian.calaby@gmail.com>

Thanks,

-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
