From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [build failure] hp-plus.c: (.text+0xd7c1a): undefined reference
 to `ei_close'
Date: Thu, 24 Jul 2008 10:06:15 +0100
Message-ID: <20080724100615.764bac36@lxorguk.ukuu.org.uk>
References: <20080721.233512.128618365.anemo@mba.ocn.ne.jp>
	<20080721191519.GA15843@elte.hu>
	<20080721214258.787a67ca@lxorguk.ukuu.org.uk>
	<20080722072334.GA25241@elte.hu>
	<48865899.3030209@garzik.org>
	<20080723104520.GA20672@elte.hu>
	<20080724052603.GA8744@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	Atsushi Nemoto <anemo@mba.ocn.ne.jp>, jgarzik@redhat.com,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:48004 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751104AbYGXJZK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 05:25:10 -0400
In-Reply-To: <20080724052603.GA8744@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Jul 2008 07:26:03 +0200
Ingo Molnar <mingo@elte.hu> wrote:

> 
> not sure it's known but despite all the fixes i still get:

I'll have a look at this next week or possibly the week after. The
original patches worked but they spent 3 months going round in circles
and I've completely given up even trying to work out what happened or why
all the previous updates I sent were ignored.

Alan
