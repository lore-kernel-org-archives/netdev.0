From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH] [ATM] he: Fix __init/__devinit conflict
Date: Mon, 25 Sep 2006 05:56:28 -0400
Message-ID: <200609250956.k8P9uS5m025424@cmf.nrl.navy.mil>
References: <20060924.201118.71090751.davem@davemloft.net>
Reply-To: chas3@users.sourceforge.net
Cc: roland@digitalvampire.org, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:39933 "EHLO
	ginger.cmf.nrl.navy.mil") by vger.kernel.org with ESMTP
	id S1750878AbWIYJ4z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Sep 2006 05:56:55 -0400
To: David Miller <davem@davemloft.net>
Reply-To: chas3@users.sourceforge.net
In-reply-to: <20060924.201118.71090751.davem@davemloft.net> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In message <20060924.201118.71090751.davem@davemloft.net>,David Miller writes:
>Chas, as a subsystem maintainer, if you change a submitter's patch in
>a significant and non-trivial way, you should at least mention a brief
>reason why you did that.  In this case, why did you delete all of
>Roland's __init/__devinit transformations except one when they all
>were necessary to fix this bug?

i submitted roland patch without modification and therefore
without comment.  i did change the author field of the patch
unintentionally (which wont happen in the future).
