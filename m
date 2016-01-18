From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Subject: Re: [PATCHv2 1/4] net: phy: at803x: Don't set gbit features for the
 AR8030 phy
Date: Mon, 18 Jan 2016 01:24:04 +0100
Message-ID: <CAFBinCCnmHLJWoFG+mzE638E7h+Z38i3QW8iH2JhTBoHJVotkQ@mail.gmail.com>
References: <1452819324-4527-1-git-send-email-martin.blumenstingl@googlemail.com>
 <20160117.191743.972127939780068329.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com, daniel@zonque.org,
	Fabio Estevam <festevam@gmail.com>, mans@mansr.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:33951 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753179AbcARAYZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jan 2016 19:24:25 -0500
Received: by mail-wm0-f51.google.com with SMTP id u188so84625137wmu.1
        for <netdev@vger.kernel.org>; Sun, 17 Jan 2016 16:24:25 -0800 (PST)
In-Reply-To: <20160117.191743.972127939780068329.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 18, 2016 at 1:17 AM, David Miller <davem@davemloft.net> wrote:
> Series applied, but this is not the proper way to send a patch series.
Thanks!

> A patch series describes a logically related group of changes, therefore
> you must submit first a "[PATCH 0/N] ..." posting that clearly and fully
> describes what the patch series is doing at a high level, and why.
Noted. I initially did this for v1 but forgot it for v2 - sorry.
