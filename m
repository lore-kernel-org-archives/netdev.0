From: Sebastian Siewior <netdev@ml.breakpoint.cc>
Subject: Re: [PATCH] [PS3] gelic wireless driver needs MAC80211 support
Date: Mon, 25 Feb 2008 12:16:49 +0100
Message-ID: <20080225111649.GA24352@Chamillionaire.breakpoint.cc>
References: <20080223193517.GA6704@Chamillionaire.breakpoint.cc> <47C0815F.7020100@pobox.com> <1203934436.13162.64.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Masakazu Mokuno <mokuno@sm.sony.co.jp>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:52975 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751082AbYBYLUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2008 06:20:22 -0500
Content-Disposition: inline
In-Reply-To: <1203934436.13162.64.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Johannes Berg | 2008-02-25 11:13:56 [+0100]:

>That seems completely wrong since it's a full-mac "chip" (implemented in
>the HV or so maybe). What exactly does it need from mac80211?
Nothing, please drop. I've sent another patch which enables WEXT what is
the correct thing to do. Sorry for the noise.

>johannes

Sebastian
