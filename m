From: David Miller <davem@davemloft.net>
Subject: Re: [ROSE] 2.6.29 rose patch missing in 2.6.30
Date: Sun, 21 Jun 2009 03:56:59 -0700 (PDT)
Message-ID: <20090621.035659.93001317.davem@davemloft.net>
References: <4A3E0EB2.7020106@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f6bvp@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49986
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751831AbZFUK4z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2009 06:56:55 -0400
In-Reply-To: <4A3E0EB2.7020106@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bernard Pidoux F6BVP <f6bvp@free.fr>
Date: Sun, 21 Jun 2009 12:42:58 +0200

> Hi David,
> 
> Problems with ROSE protocol came back with 2.6.30 kernel.
> I discovered the reason.
> Rose patch I submitted in November was applied in kernels until
> 2.6.29.4.
> However this patch is not present in 2.6.30.
> 
> Is there any reason ?
> 
> Here are the reference to my patch and your acceptance message :

Alan Cox found them to be incorrect and we had to revert
them.
