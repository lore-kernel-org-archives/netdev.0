From: Roland Dreier <roland@kernel.org>
Subject: Re: [PATCH] be2net: Remove unused OFFSET_IN_PAGE() macro
Date: Mon, 5 Mar 2012 12:39:30 -0800
Message-ID: <CAL1RGDV0Bn+u8aKVDV4Wfbho34_hgdXyEHqRmqg0uYX1rGA6hg@mail.gmail.com>
References: <1330584046-3938-1-git-send-email-roland@kernel.org> <20120301.172219.992238183401523944.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog111.obsmtp.com ([74.125.245.90]:35123 "HELO
	na3sys010aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S965039Ab2CEUj5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 15:39:57 -0500
Received: by mail-pz0-f51.google.com with SMTP id y9so6427023dad.38
        for <netdev@vger.kernel.org>; Mon, 05 Mar 2012 12:39:50 -0800 (PST)
In-Reply-To: <20120301.172219.992238183401523944.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 1, 2012 at 2:22 PM, David Miller <davem@davemloft.net> wrote:
> I assume you are aware of the same issue in the be2iscsi driver.

Yeah, patch already sent:
http://www.spinics.net/lists/linux-scsi/msg57754.html

but the SCSI maintainer is not as responsive as the networking one ;)

 - R.
