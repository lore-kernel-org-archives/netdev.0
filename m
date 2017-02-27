From: Leon Goldberg <lgoldber@redhat.com>
Subject: netlink 802.1ad info events
Date: Mon, 27 Feb 2017 11:34:49 +0200
Message-ID: <CA+mNUtAExx2-cRqDGi=3Vcgy5C8h=NpOV-e1DAtbRfnWJtBMzA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dan Kenigsberg <danken@redhat.com>, Edward Haas <ehaas@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:33790 "EHLO
        mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751636AbdB0JfO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 04:35:14 -0500
Received: by mail-lf0-f43.google.com with SMTP id a6so7904567lfa.0
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 01:34:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey,

I'm interested in being able to parse bond mode 4 information using
netlink events. I saw this patch[1] that adds ad_info to netlink and
wonder if a patch which adds event support was ever introduced (I've
tried digging around but found nothing).

[1] https://www.spinics.net/lists/netdev/msg263846.html

Thanks,
Leon
