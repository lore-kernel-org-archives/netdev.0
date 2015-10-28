From: David Jander <david@protonic.nl>
Subject: Re: BUG: fsl FEC ethernet tx checksum offloading doesn't work with
 RMII interface
Date: Wed, 28 Oct 2015 13:36:02 +0100
Message-ID: <20151028133602.0f48dac9@archvile>
References: <20151028104854.025430ce@archvile>
	<20151028111414.GJ8644@n2100.arm.linux.org.uk>
	<20151028121918.4884b42e@archvile>
	<CAOMZO5D=7Okx-Lju5uzMCXC+_8ETDVmEOfWU7ZD0byZszDSV3A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from protonic.xs4all.nl ([83.163.252.89]:27662 "EHLO
	protonic.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965504AbbJ1MgE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2015 08:36:04 -0400
In-Reply-To: <CAOMZO5D=7Okx-Lju5uzMCXC+_8ETDVmEOfWU7ZD0byZszDSV3A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Oct 2015 10:31:17 -0200
Fabio Estevam <festevam@gmail.com> wrote:

> On Wed, Oct 28, 2015 at 9:19 AM, David Jander <david@protonic.nl> wrote:
> 
> > Sorry, I somehow assumed it was obvious I'd report against latest
> > mainline... I'm on 4.3-rc7.
> 
> Are you able to find out a previous kernel version that does not
> exhibit this failure?

I can search further down, but 4.1 is also broken.
Are there specific changes or versions you are suspicious of?
Russel mentioned something similar being fixed in the past... any pointers to
this fix, so I can investigate whether this has any relation?

Best regards,

-- 
David Jander
Protonic Holland.
