From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net V2 0/2] net: delete duplicate dev_set_rx_mode() call
Date: Mon, 16 Jun 2014 10:14:55 -0700
Message-ID: <CAHA+R7PHTGDJ2X15G1gYKK5vV68g4d-jEfNESQR4HiEoxxv=PA@mail.gmail.com>
References: <cover.1402926490.git.panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Weiping Pan <panweiping3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f172.google.com ([209.85.216.172]:58199 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751545AbaFPRO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2014 13:14:56 -0400
Received: by mail-qc0-f172.google.com with SMTP id o8so8351395qcw.31
        for <netdev@vger.kernel.org>; Mon, 16 Jun 2014 10:14:55 -0700 (PDT)
In-Reply-To: <cover.1402926490.git.panweiping3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 16, 2014 at 6:57 AM, Weiping Pan <panweiping3@gmail.com> wrote:
> This patchset delete duplicate dev_set_rx_mode() call, and it also make some
> functions return void instead of int.
>

Why for -net not -net-next?
This probably doesn't fix any bug, at least the second one.
