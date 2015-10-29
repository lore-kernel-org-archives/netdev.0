From: Fabio Estevam <festevam@gmail.com>
Subject: Re: BUG: fsl FEC ethernet tx checksum offloading doesn't work with
 RMII interface
Date: Thu, 29 Oct 2015 12:50:58 -0200
Message-ID: <CAOMZO5CHYSWgoJyFMRMe3Q4BmHd6ndY-AU4rroBbx+jB=Y0uDg@mail.gmail.com>
References: <20151028104854.025430ce@archvile>
	<20151028111414.GJ8644@n2100.arm.linux.org.uk>
	<20151028121918.4884b42e@archvile>
	<CAOMZO5D=7Okx-Lju5uzMCXC+_8ETDVmEOfWU7ZD0byZszDSV3A@mail.gmail.com>
	<20151028133602.0f48dac9@archvile>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: David Jander <david@protonic.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:38903 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751044AbbJ2Ou6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 10:50:58 -0400
Received: by igbdj2 with SMTP id dj2so32098082igb.1
        for <netdev@vger.kernel.org>; Thu, 29 Oct 2015 07:50:58 -0700 (PDT)
In-Reply-To: <20151028133602.0f48dac9@archvile>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 28, 2015 at 10:36 AM, David Jander <david@protonic.nl> wrote:

> I can search further down, but 4.1 is also broken.
> Are there specific changes or versions you are suspicious of?

I was just trying to understand if this was a regression or if it has
always been broken.
