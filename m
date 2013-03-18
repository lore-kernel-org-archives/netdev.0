From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCHv3 vringh] caif_virtio: Introduce caif over virtio
Date: Mon, 18 Mar 2013 14:08:58 +1030
Message-ID: <87li9ls7fx.fsf@rustcorp.com.au>
References: <1363340537-16011-1-git-send-email-erwan.yvin@stericsson.com> <20130317.121436.461735238002154159.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rusty@ruscorp.com.au, sjur.brandeland@stericsson.com,
	linus.walleij@stericsson.com, ohad@wizery.com,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, erwan.yvin@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:51345 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751848Ab3CRISL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Mar 2013 04:18:11 -0400
In-Reply-To: <20130317.121436.461735238002154159.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Erwan Yvin <erwan.yvin@stericsson.com>
> Date: Fri, 15 Mar 2013 10:42:17 +0100
>
>> caif-virtio is going to replace caif-shm.
>> This patch should be merged in rusty's tree. (vringh)
>> because there is a dependency with vringh wrapper.
>
> Feel free to add my:
>
> Acked-by: David S. Miller <davem@davemloft.net>

Thanks, applied to my vringh branch.  I'll repost it all, to give you
and Sjur a chance to make sure I've integrated correctly.

Thanks,
Rusty.
