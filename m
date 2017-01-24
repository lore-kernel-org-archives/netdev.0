From: Sriram V <vshrirama@gmail.com>
Subject: network status
Date: Wed, 25 Jan 2017 01:09:54 +0530
Message-ID: <CAH9_wRNWRG0zY20OCXyL_MDci3Bw+RYDjQJCu15+c82C1Eon=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f172.google.com ([209.85.217.172]:35635 "EHLO
        mail-ua0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750708AbdAXTjz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 14:39:55 -0500
Received: by mail-ua0-f172.google.com with SMTP id y9so142770854uae.2
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 11:39:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Apologies in case, this is not the right list of this question.

I wanted to check, How can i find out if a network status has changed

1. How can the user application find out if the link status has changed?
2. what changes do i need to add in the driver to indicate to the user
applications that ethernet cable has been plugged in or unplugged.

3. How should a user application know the status change (Should the
userapp poll on the interface/is there an uevent interface to indicate
the link status change)

Thanks.
Sriram
