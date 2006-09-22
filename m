From: James Morris <jmorris@namei.org>
Subject: Re: Is TCP over IPsec broken in 2.6.18?
Date: Fri, 22 Sep 2006 11:47:07 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0609221146340.7950@d.namei>
References: <20060922112948.GA17335@2ka.mipt.ru> <20060922121920.GA3172@2ka.mipt.ru>
 <4513D5B5.6090301@trash.net> <20060922140318.GA14408@2ka.mipt.ru>
 <Pine.LNX.4.64.0609221112000.7628@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:24789 "EHLO
	mail8.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S964769AbWIVPrJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Sep 2006 11:47:09 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <Pine.LNX.4.64.0609221112000.7628@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 22 Sep 2006, James Morris wrote:

> Can you try this with either a fully manual config (setkey only) or 
> openswan?

Just confirming that everything seems to be working ok with manual config 
under 2.6.18 (haven't tried racoon yet).


-- 
James Morris
<jmorris@namei.org>
