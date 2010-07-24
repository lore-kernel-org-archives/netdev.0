From: "Gustavo F. Padovan" <gustavo@padovan.org>
Subject: Re: [PATCH NEXT 2/2] qlcnic: diag fixes
Date: Sat, 24 Jul 2010 13:53:43 -0300
Message-ID: <20100724165343.GC9787@vigoh>
References: <1279956266-23445-1-git-send-email-amit.salecha@qlogic.com>
 <1279956266-23445-3-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	ameen.rahman@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:65090 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755992Ab0GXQxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Jul 2010 12:53:42 -0400
Received: by gyg10 with SMTP id 10so490145gyg.19
        for <netdev@vger.kernel.org>; Sat, 24 Jul 2010 09:53:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1279956266-23445-3-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Amit,

* amit.salecha@qlogic.com <amit.salecha@qlogic.com> [2010-07-24 00:24:26 -0700]:

> From: Amit Kumar Salecha <amit.salecha@qlogic.com>
> 
> o Loopback not supported for virtual function.
> o netif_device_attach was missing in error path from
>   qlcnic_diag_alloc_res

This second part should be a new commit actually. It fixes a different
thing.


-- 
Gustavo F. Padovan
http://padovan.org
