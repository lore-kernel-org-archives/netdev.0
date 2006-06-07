From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: Problem authenticating using WPA with bcm43xx-softmac
Date: Wed, 07 Jun 2006 11:09:26 -0500
Message-ID: <4486FA36.4030203@lwfinger.net>
References: <4485D66B.7080108@lwfinger.net> <1149682213.3999.14.camel@johannes> <4486F513.5050906@lwfinger.net> <1149695470.3925.7.camel@johannes> <4486F866.9040901@errno.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:38850 "EHLO
	mtiwmhc11.worldnet.att.net") by vger.kernel.org with ESMTP
	id S932285AbWFGQJd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jun 2006 12:09:33 -0400
To: Sam Leffler <sam@errno.com>
In-Reply-To: <4486F866.9040901@errno.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sam Leffler wrote:
> Beware of the order of IE's in the management frames; some AP's are
> touchy about this.

That may be the cause here as the behavior when I changed AP's from the Linux-based model to one 
with VXWorks.

Larry
