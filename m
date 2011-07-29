From: Chris Clayton <chris2553@googlemail.com>
Subject: Re: [PATCH] Fix cdc-phonet build
Date: Fri, 29 Jul 2011 21:49:58 +0100
Message-ID: <201107292149.58759.chris2553@googlemail.com>
References: <201107262320.22338.chris2553@googlemail.com> <20110727.224117.389682636642939049.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:40916 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752598Ab1G2UuK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2011 16:50:10 -0400
Received: by wwe5 with SMTP id 5so3929809wwe.1
        for <netdev@vger.kernel.org>; Fri, 29 Jul 2011 13:50:09 -0700 (PDT)
In-Reply-To: <20110727.224117.389682636642939049.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 28 July 2011 06:41:17 David Miller wrote:
> From: Chris Clayton <chris2553@googlemail.com>
> Date: Tue, 26 Jul 2011 23:20:22 +0100
>
> > cdc-phonet does not presently build on linux-3.0 because there is no
> > entry for it in drivers/net/Makefile. This patch adds that entry.
> >
> > Signed-off-by: Chris Clayton <chris2553@googlemail.com>
>
> Applied, thanks.

Actually, I've just checked and the same problem exists in 2.6.39.3, so once the patch is Linus' 
tree, I guess it should go in stable too. Do you have that in hand, David or should I send to 
stable once the patch is applied to mainline?

-- 
The more I see, the more I know. The more I know, the less I understand. Changing Man - Paul Weller
