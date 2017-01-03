From: Itai Fiat Gecht <itaifg@infinidat.com>
Subject: What are "forward retransmits"?
Date: Tue, 3 Jan 2017 10:34:54 +0200
Message-ID: <CAAPSPUuZNbmA=Nt2bWat-f0ka1YtodCFg_nZSRrzGzR5TV+v9Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f174.google.com ([209.85.161.174]:34348 "EHLO
        mail-yw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932930AbdACIez (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 03:34:55 -0500
Received: by mail-yw0-f174.google.com with SMTP id t125so282934654ywc.1
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2017 00:34:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

What are the "forward retransmits" shown by netstat? Is there an RFC
or other documentation describing them? I could not figure this out
from tcp_output.c.

Sample netstat output:

    106926 fast retransmits
    5149 forward retransmits
    915 retransmits in slow start

Sincerely yours,

Itai
