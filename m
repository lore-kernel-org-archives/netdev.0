From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: net: fix network drivers ndo_start_xmit() return values
Date: Tue, 16 Jun 2009 09:55:30 +0000
Message-ID: <20090616095530.GC6106@ff.dom.local>
References: <4A367E14.4040104@trash.net> <20090616061603.GA4494@ff.dom.local> <20090616071204.GB4494@ff.dom.local> <4A376665.6000801@trash.net> <20090616094608.GB6106@ff.dom.local> <4A376ABC.2020303@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, perex@perex.cz
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f211.google.com ([209.85.220.211]:63682 "EHLO
	mail-fx0-f211.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752638AbZFPJzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 05:55:36 -0400
Received: by fxm7 with SMTP id 7so500494fxm.37
        for <netdev@vger.kernel.org>; Tue, 16 Jun 2009 02:55:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A376ABC.2020303@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 16, 2009 at 11:49:48AM +0200, Patrick McHardy wrote:
> Jarek Poplawski wrote:
...
>> I thought you wanted to replace it with NETDEV_TX_OK, but now I see
>> you leave both variants in the last patch, so I'm not sure...
>
> I wanted to do that in a seperate patch at the end of the merge
> window to avoid causing too much clashes with this (and catch
> any new drivers).

NETDEV_TX_OK!
Jarek P. 
