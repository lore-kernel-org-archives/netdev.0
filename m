From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next] drivers/net: fixup comments after "Future-proof
 tunnel offload handlers"
Date: Mon, 11 Jul 2016 09:03:54 -0700
Message-ID: <CAKgT0UdC+mdpVZeZESVwh80r5TiSbau3_rXsymNNTLPpTw53AQ@mail.gmail.com>
References: <a1439b9645eec067ebe03a4e2d5228ed78f0e85e.1468235257.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	Alexander Duyck <aduyck@mirantis.com>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f41.google.com ([209.85.214.41]:38338 "EHLO
	mail-it0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755286AbcGKQD4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 12:03:56 -0400
Received: by mail-it0-f41.google.com with SMTP id h190so65670183ith.1
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 09:03:55 -0700 (PDT)
In-Reply-To: <a1439b9645eec067ebe03a4e2d5228ed78f0e85e.1468235257.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 11, 2016 at 4:12 AM, Sabrina Dubroca <sd@queasysnail.net> wrote:
> Some comments weren't updated to reflect the renaming of ndo's and the
> change of arguments.
>
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

The changes look good to me.  Thanks for cleaning this up.

Acked-by: Alexander Duyck <aduyck@mirantis.com>
