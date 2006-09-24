From: Patrick McHardy <kaber@trash.net>
Subject: Re: Is TCP over IPsec broken in 2.6.18?
Date: Sun, 24 Sep 2006 11:08:18 +0200
Message-ID: <45164B02.1090801@trash.net>
References: <20060922112948.GA17335@2ka.mipt.ru> <20060922121920.GA3172@2ka.mipt.ru> <4513D5B5.6090301@trash.net> <20060922140318.GA14408@2ka.mipt.ru> <Pine.LNX.4.64.0609221112000.7628@d.namei> <20060923042914.GC24099@2ka.mipt.ru> <Pine.LNX.4.64.0609240106270.24276@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:25248 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751506AbWIXJLj
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Sep 2006 05:11:39 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0609240106270.24276@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Morris wrote:
> On Sat, 23 Sep 2006, Evgeniy Polyakov wrote:
> 
> 
>>I never saw unencrypted packets before.
> 
> 
> It's normal and expected, perhaps you didn't notice or had tcpdump 
> filtering them.

He's talking about transport mode, unencrypted packet should
only be visible in tunnel mode.


