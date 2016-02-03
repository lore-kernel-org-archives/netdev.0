From: Dan Streetman <dan.streetman@canonical.com>
Subject: bnx2x commits needed to use 7.51.10 firmware?
Date: Tue, 2 Feb 2016 19:20:12 -0500
Message-ID: <CAOZ2QJOX8JLgCpjohncBhove8zyZ8QMOUGLZHEr-h1D1b-qt7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Ariel Elior <ariel.elior@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:33889 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755282AbcBCAUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 19:20:52 -0500
Received: by mail-ig0-f173.google.com with SMTP id ik10so73943349igb.1
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 16:20:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ariel,

I'm trying to update the bnx2x driver in Ubuntu trusty (3.13 kernel)
release to use the 7.51.10 firmware; can you help me determine which
commits need to be backported?

Some reference is in Launchpad bug 1454286:
https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1454286

basically, there are 87 commits between the current bnx2x driver level
in Ubuntu trusty's kernel, and commit e42780b where the bnx2x driver
is acutally updated to use the 7.51.10 firmware.  Can you provide
guidance to which commits should be pulled back?  Do all 87 of them
need to be included?

Thanks!
