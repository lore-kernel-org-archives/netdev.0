From: "rae l" <crquan@gmail.com>
Subject: Re: [PATCH 1/2] net/: all net/ cleanup with ARRAY_SIZE
Date: Fri, 21 Sep 2007 00:49:15 +0800
Message-ID: <91b13c310709200949x4b0c6db1kd408c19d931a1d09@mail.gmail.com>
References: <Pine.LNX.4.64.0709020235420.22012@localhost.localdomain>
	 <11887290181154-git-send-email-crquan@gmail.com>
	 <20070916.164203.38709930.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: rpjday@mindspring.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, cr_quan@163.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:6633 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755625AbXITQtR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 12:49:17 -0400
Received: by ug-out-1314.google.com with SMTP id z38so413366ugc
        for <netdev@vger.kernel.org>; Thu, 20 Sep 2007 09:49:16 -0700 (PDT)
In-Reply-To: <20070916.164203.38709930.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/17/07, David Miller <davem@davemloft.net> wrote:
> From: Denis Cheng <crquan@gmail.com>
> Date: Sun,  2 Sep 2007 18:30:17 +0800
>
> > Signed-off-by: Denis Cheng <crquan@gmail.com>
>
> You already submitted the net/ipv4/af_inet.c case
> seperately, so I had to remove it from this patch for
> it to apply properly.
>
> Please keep your patches straight to avoid problems
> like this.
I just can say sorry. But at that time, I'm not sure the former
specific patch to net/ipv4/af_inet.c would be applied, and then I
realized that change should be done with every subsystem in the kernel
source, so I regenerate a new patch for the whole net/ subsystem; In
this situation, I think I should give an announcement to make the
former patch deprecated, shouldn't it?
However, I'll be more cautious with patches.

>
> Thans.
Thanks for applying.

>


-- 
Denis Cheng
