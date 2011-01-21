From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] tlan: Use pr_fmt, pr_<level> and netdev_<level>,
 remove changelog
Date: Fri, 21 Jan 2011 13:09:21 -0800
Message-ID: <1295644161.25868.35.camel@Joe-Laptop>
References: <4D260ED0.5040301@iki.fi>
	 <1294339817-31434-1-git-send-email-sakari.ailus@iki.fi>
	 <1294354088.12561.295.camel@Joe-Laptop>  <4D39F144.6090404@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Samuel Chessman <chessman@tux.org>
To: Sakari Ailus <sakari.ailus@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3250 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751577Ab1AUVJX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jan 2011 16:09:23 -0500
In-Reply-To: <4D39F144.6090404@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-01-21 at 22:49 +0200, Sakari Ailus wrote:
> Joe Perches wrote:
> > Neatening and standardization to the standard logging mechanisms.
> > The changelog isn't useful anymore.
> > Miscellaneous speen/speed typo correction.
> I definitely think it's good to replace pr_ prints with netdev_* macros. 
[]
> I think these prints could be removed by a separate patch before this 
> one. Would you like to do that, or shall I? :-)

Hi.

Why don't you pick and choose the parts you think appropriate,
convert the stuff you think should be converted and submit it
as you think best.

There's no need to wait for me to do it or attribute it to me.

cheers, Joe



