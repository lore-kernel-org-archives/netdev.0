From: Martin Schmidt <mschmidt00000@gmail.com>
Subject: How to debug iproute2 based policy routing?
Date: Wed, 8 Feb 2012 12:56:51 +0100
Message-ID: <CAPTK99C8bRjdZjEU+sj8mOPH64a1_ObO-deqC2EFLhcWgbYqSA@mail.gmail.com>
References: <CAPTK99Cf5jSVejqW23BrsrHqNn56cj2QB48KiTV=XmWq5pi6tA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m020-f174.google.com ([209.85.217.174]:50095 "EHLO
	mail-lpp01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756372Ab2BHL4w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 06:56:52 -0500
Received: by lbom4 with SMTP id m4so200105lbo.19
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2012 03:56:51 -0800 (PST)
In-Reply-To: <CAPTK99Cf5jSVejqW23BrsrHqNn56cj2QB48KiTV=XmWq5pi6tA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have a somewhat complicated iproute2 based policy routing scenario
on Ubuntu server.
It mainly works as needed, but under some circumstances it weirdly
misroutes some packets, but not all.
I've already been struggling with this for long, but now it seems to
be a routing bug, although not sure.

To get closer I need a way to verbose log the full routing decision
process for all outgoing packets.
How can I achieve this? With some kernel configuration options, or any
other ideas?

Thanks!
