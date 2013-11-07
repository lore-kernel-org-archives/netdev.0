From: Joshua Richenhagen <richenhagen@gmail.com>
Subject: BCM57786 driver
Date: Thu, 7 Nov 2013 12:12:07 +0100
Message-ID: <CAJZ9B5s87PHb3=eAxOy1dDo59Tq8pQbR78-=_zyKt8-0g5tGdg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:49257 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751783Ab3KGLMH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 06:12:07 -0500
Received: by mail-pa0-f47.google.com with SMTP id lf10so455581pab.6
        for <netdev@vger.kernel.org>; Thu, 07 Nov 2013 03:12:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello everyone,

I recently bought a Acer Aspire E1-572 notebook with the gigabit
ethernet controller Broadcom Corporation NetXtreme BCM57786 builtin.
However I can't get it working under Ubuntu, neither with standard
kernel nor with newest mainline kernel 3.12 final. I doesn't seem to
be recognized at all, does a driver for this chip exists, or do I have
to wait till one gets released? How far is the developmend process?

Thanks in advance
Joshua
