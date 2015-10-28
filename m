From: Fabio Estevam <festevam@gmail.com>
Subject: Re: BUG: fsl FEC ethernet tx checksum offloading doesn't work with
 RMII interface
Date: Wed, 28 Oct 2015 10:31:17 -0200
Message-ID: <CAOMZO5D=7Okx-Lju5uzMCXC+_8ETDVmEOfWU7ZD0byZszDSV3A@mail.gmail.com>
References: <20151028104854.025430ce@archvile>
	<20151028111414.GJ8644@n2100.arm.linux.org.uk>
	<20151028121918.4884b42e@archvile>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: David Jander <david@protonic.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:35647 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755484AbbJ1MbS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2015 08:31:18 -0400
Received: by igpw7 with SMTP id w7so2014322igp.0
        for <netdev@vger.kernel.org>; Wed, 28 Oct 2015 05:31:17 -0700 (PDT)
In-Reply-To: <20151028121918.4884b42e@archvile>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 28, 2015 at 9:19 AM, David Jander <david@protonic.nl> wrote:

> Sorry, I somehow assumed it was obvious I'd report against latest mainline...
> I'm on 4.3-rc7.

Are you able to find out a previous kernel version that does not
exhibit this failure?
