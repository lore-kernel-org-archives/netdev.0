From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: Bridge extensions to iproute2
Date: Tue, 10 Jul 2012 15:01:26 -0700
Message-ID: <CAHo-OozFCrcx4FpsuNzEV4Cp_4hbVw896utpstYL2qcD1EwCyA@mail.gmail.com>
References: <CAHo-Ooyk_=UYsEtz-y6hupCtMOgKz2DF+j1BOnSsmAfm-5Bkqg@mail.gmail.com>
	<20120710145821.748c00be@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux NetDev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:61597 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752809Ab2GJWB1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 18:01:27 -0400
Received: by obbuo13 with SMTP id uo13so593975obb.19
        for <netdev@vger.kernel.org>; Tue, 10 Jul 2012 15:01:26 -0700 (PDT)
In-Reply-To: <20120710145821.748c00be@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I will get back to these. There wasn't a motivation to go fast because
> there wasn't a user of these. Now with fdb offload support they are needed.

Do you have some semi-ready patches that could be used for test purposes?

While it looks like the forwarding database capability is there in the kernel,
I can't currently find an interface to turn learning off.
