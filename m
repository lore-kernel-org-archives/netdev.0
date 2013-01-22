From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 20/33] net: Convert to devm_ioremap_resource()
Date: Tue, 22 Jan 2013 13:03:06 +0000
Message-ID: <201301221303.06785.arnd@arndb.de>
References: <1358762966-20791-1-git-send-email-thierry.reding@avionic-design.de> <20130121.152913.1377695352860141642.davem@davemloft.net> <20130122065629.GA14523@avionic-0098.adnet.avionic-design.de>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	gregkh@linuxfoundation.org, dmitry.torokhov@gmail.com,
	w.sang@pengutronix.de, netdev@vger.kernel.org
To: Thierry Reding <thierry.reding@avionic-design.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:52259 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752132Ab3AVND0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 08:03:26 -0500
In-Reply-To: <20130122065629.GA14523@avionic-0098.adnet.avionic-design.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 22 January 2013, Thierry Reding wrote:
> I planned to do so initially, but that yielded a Cc list of 156 people
> and mailing lists, which I thought wasn't going to go down so well
> either. In general I like Cc'ing everyone concerned on all patches of
> the series, specifically for reasons of context. Some people have been
> annoyed when I did so. Still, for small series where only a few dozen
> people are concerned that seems to me to be the best way. But 156 email
> addresses is a different story.
> 
> Either you add to many people or you don't add enough. Where do we draw
> the line?

I've had the same problem a couple of times. The best compromise seems
to be to Cc only the top-level subsystem maintainers and mailing lists
on the first email.

	Arnd
