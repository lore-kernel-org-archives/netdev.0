From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: inconsistency of ethtool feature names for get vs. set
Date: Thu, 2 Jan 2014 22:12:55 +0200
Message-ID: <CAJZOPZJZVH-ajrytOT9u70s4rK+n38ssDvEz9zEc0NQn2zywOQ@mail.gmail.com>
References: <52C535B9.7080208@mellanox.com>
	<1388675034.1607.9.camel@bwh-desktop.uk.level5networks.com>
	<1388688114.9947.30.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <ogerlitz@mellanox.com>, netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:49117 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740AbaABUMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 15:12:55 -0500
Received: by mail-pa0-f44.google.com with SMTP id fa1so15021765pad.3
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 12:12:55 -0800 (PST)
In-Reply-To: <1388688114.9947.30.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 2, 2014 at 8:41 PM, Ben Hutchings <bhutchings@solarflare.com> wrote:

> Just to be clear, I do see that there's a problem here but the fix may
> have to be mostly or entirely in documentation rather than code.

Ben, I am fine with at least starting with documenting this and see
where it takes us, can you pick it up?
