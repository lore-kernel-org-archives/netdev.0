From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: on bnx2x firmware...
Date: Wed, 2 Nov 2011 21:36:40 -0700
Message-ID: <CAHo-OozBEC1dpzt2vXvTCgSw=FsE_kPNEzrTUYrUpfwSqv2Dzg@mail.gmail.com>
References: <CAHo-OowF1LNmL0P_Rt=oKmhZMt=CVaVsAYkh_XqVJEOzBPXV7w@mail.gmail.com>
	<1320208614.3079.5.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux NetDev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:52286 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750849Ab1KCEgl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2011 00:36:41 -0400
Received: by ggnb2 with SMTP id b2so912628ggn.19
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2011 21:36:41 -0700 (PDT)
In-Reply-To: <1320208614.3079.5.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm assuming this means a patch to remove the obsolete/old fw from the
kernel would be accepted?

[btw. not a fan of the out-of-tree firmware, since I have to fix the
build system to work around this, but whatever, the current
schrodinger half-state is even worse...]

- Maciej
