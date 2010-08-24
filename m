From: Chetan Loke <chetanloke@gmail.com>
Subject: Time sync across adapters ....
Date: Tue, 24 Aug 2010 19:04:07 -0400
Message-ID: <AANLkTin=gtQSz1z5f4p5F40Wb4o-f31dUi8eNeKxmGTZ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:35627 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933786Ab0HXXEI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 19:04:08 -0400
Received: by fxm13 with SMTP id 13so4112316fxm.19
        for <netdev@vger.kernel.org>; Tue, 24 Aug 2010 16:04:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Other than normalizing each and every packet and comparing it w/ the
system clock, what would be a straight forward way to ensure/implement
time-sync logic across:
i) multiple adapters
AND
ii)system clock
on a multi-core system? Are there any adapters that can sync
themselves to the system clock?


Chetan
