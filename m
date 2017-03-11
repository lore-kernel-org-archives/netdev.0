From: =?UTF-8?Q?Mantas_Mikul=c4=97nas?= <grawity@gmail.com>
Subject: Re: regression (4.10) - interface remove uevents not generated
Date: Sat, 11 Mar 2017 23:24:34 +0200
Message-ID: <3aff47fb-7dde-2d21-74bc-9954560a2b51@gmail.com>
References: <d519f10b-8512-efa2-03a1-81f6e4a91c7c@gmail.com>
 <20170311195047.GA10561@outlook.office365.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Andrei Vagin <avagin@openvz.org>,
        "David S. Miller" <davem@davemloft.net>
To: Andrei Vagin <avagin@virtuozzo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f49.google.com ([209.85.215.49]:34880 "EHLO
        mail-lf0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932781AbdCKVYk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Mar 2017 16:24:40 -0500
Received: by mail-lf0-f49.google.com with SMTP id j90so52023936lfk.2
        for <netdev@vger.kernel.org>; Sat, 11 Mar 2017 13:24:39 -0800 (PST)
In-Reply-To: <20170311195047.GA10561@outlook.office365.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-03-11 21:50, Andrei Vagin wrote:
> Hi Mantas,
> 
> Thank you for the report. Could you try out the attached patch?

Thanks, I tested it on current master but it doesn't seem to help; there
still aren't any uevents for removed interfaces.

-- 
Mantas Mikulėnas <grawity@gmail.com>
