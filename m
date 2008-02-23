From: Sebastian Siewior <netdev@ml.breakpoint.cc>
Subject: Re: [PATCH] [PS3] gelic wireless driver needs MAC80211 support
Date: Sat, 23 Feb 2008 21:09:10 +0100
Message-ID: <20080223200910.GB7135@Chamillionaire.breakpoint.cc>
References: <20080223193517.GA6704@Chamillionaire.breakpoint.cc> <200802232044.59887.IvDoorn@gmail.com> <200802232050.35157.IvDoorn@gmail.com> <20080223200637.GA7135@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Masakazu Mokuno <mokuno@sm.sony.co.jp>, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:52610 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753361AbYBWUJ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2008 15:09:27 -0500
Content-Disposition: inline
In-Reply-To: <20080223200637.GA7135@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Sebastian Siewior | 2008-02-23 21:06:37 [+0100]:

>I add this to the patch desctiption and post a depends on patach
ARGH, this was CONFIG_WIRELESS_EXT and not MAC80211. You would like to
see a select or depend statement on that one?

>>Ivo
>
Sebastian
