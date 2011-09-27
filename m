From: Martin Millnert <millnert@gmail.com>
Subject: Re: intel 82599 multi-port performance
Date: Tue, 27 Sep 2011 17:30:18 +0200
Message-ID: <CAHyNd141gWO_r6bM0T6jYiMMVobBtA7uFzhG51SUivJd0-Orjw@mail.gmail.com>
References: <4E805359.2080600@gmail.com>
	<4E808A41.8040902@genband.com>
	<4E809D59.10103@gmail.com>
	<4E80A2AB.2040206@intel.com>
	<4E811C8E.8020508@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev <netdev@vger.kernel.org>
To: "J.Hwan Kim" <frog1120@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:35650 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751170Ab1I0PaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 11:30:20 -0400
Received: by fxe4 with SMTP id 4so7240818fxe.19
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2011 08:30:18 -0700 (PDT)
In-Reply-To: <4E811C8E.8020508@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi J.Hwan,

On Tue, Sep 27, 2011 at 2:45 AM, J.Hwan Kim <frog1120@gmail.com> wrote:
> I tested the 10G - 64byte frames.
> With ixgbe-modified driver, in single port, 92% of packet received in driver
> level and in 2 port we received around 42% packets.

Are you reading packet drops in the 82599's own registries (ie ethtool)?

Regards,
Martin
