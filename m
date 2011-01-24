From: Sakari Ailus <sakari.ailus@iki.fi>
Subject: Re: [PATCH] tlan: Use pr_fmt, pr_<level> and netdev_<level>, remove
 changelog
Date: Mon, 24 Jan 2011 23:54:50 +0200
Message-ID: <4D3DF52A.50705@iki.fi>
References: <4D260ED0.5040301@iki.fi>	 <1294339817-31434-1-git-send-email-sakari.ailus@iki.fi>	 <1294354088.12561.295.camel@Joe-Laptop>  <4D39F144.6090404@iki.fi> <1295644161.25868.35.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Samuel Chessman <chessman@tux.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-68.nebula.fi ([83.145.220.68]:52190 "EHLO
	smtp-68.nebula.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751342Ab1AXVyx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jan 2011 16:54:53 -0500
In-Reply-To: <1295644161.25868.35.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches wrote:
> On Fri, 2011-01-21 at 22:49 +0200, Sakari Ailus wrote:
>> Joe Perches wrote:
>>> Neatening and standardization to the standard logging mechanisms.
>>> The changelog isn't useful anymore.
>>> Miscellaneous speen/speed typo correction.
>> I definitely think it's good to replace pr_ prints with netdev_* macros.
> []
>> I think these prints could be removed by a separate patch before this
>> one. Would you like to do that, or shall I? :-)
>
> Hi.

Hi Joe,

> Why don't you pick and choose the parts you think appropriate,
> convert the stuff you think should be converted and submit it
> as you think best.
>
> There's no need to wait for me to do it or attribute it to me.

I'll incorporate your patch to a tlan patchset. Thanks.

Regards,

-- 
Sakari Ailus
sakari.ailus@iki.fi
