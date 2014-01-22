From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v4 0/3] reciprocal_divide update
Date: Wed, 22 Jan 2014 02:24:44 +0100
Message-ID: <20140122012444.GA28225@order.stressinduktion.org>
References: <1390352550-4511-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:56749 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754494AbaAVBYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 20:24:46 -0500
Content-Disposition: inline
In-Reply-To: <1390352550-4511-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 22, 2014 at 02:02:27AM +0100, Hannes Frederic Sowa wrote:
> v1->v2:
>  - changed name to prandom_u32_max in p1
>  - changed name to trim in p2
>  - reworked code in p3
> v2->v3:
>  - p1 and p3 stays unchanged, only small update in commit
>    message in p3
>  - changed name to reciprocal_scale in p2
>  - fixed kernel doc format
> v3->v4:
>  - pseduo -> pseudo (thanks to Tilman Schmidt)

Oh, David, I messed up the rebase and the change is actually not part of this
series. Please discard this.

I'll double-check and resend soon and finally get my needed sleep then. ;)

Thanks,

  Hannes
