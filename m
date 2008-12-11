From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Lockup with tun/tap/bridge interface deregistration.
Date: Thu, 11 Dec 2008 10:43:03 +0000
Message-ID: <20081211104303.GC4129@ff.dom.local>
References: <87fxkwhyyq.fsf@barad-dur.regala.cx> <20081211102421.GB4129@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	kernel@gentoo.org
To: Mathieu SEGAUD <mathieu.segaud@regala.cx>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f17.google.com ([209.85.219.17]:65466 "EHLO
	mail-ew0-f17.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755014AbYLKKnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 05:43:10 -0500
Received: by ewy10 with SMTP id 10so1295957ewy.13
        for <netdev@vger.kernel.org>; Thu, 11 Dec 2008 02:43:08 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20081211102421.GB4129@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 11, 2008 at 10:24:21AM +0000, Jarek Poplawski wrote:
...
> Could you try e.g. 2.6.27.7 or something with this patch?:
> 
> http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.27.y.git;a=commit;h=58ec3b4db9eb5a28e3aec5f407a54e28f7039c19

Oops! 2.6.27.4 has this too...

Sorry,
Jarek P.
