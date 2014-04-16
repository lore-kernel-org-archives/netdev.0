From: Sharat Masetty <sharat04@gmail.com>
Subject: Question on Lockless TX
Date: Tue, 15 Apr 2014 22:29:14 -0600
Message-ID: <CAJzFV37OPJVVx3rO=L9RRZFn8NajiR1HZuZEZ8M3SepXTsMQ6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f170.google.com ([74.125.82.170]:52913 "EHLO
	mail-we0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750928AbaDPE3P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2014 00:29:15 -0400
Received: by mail-we0-f170.google.com with SMTP id w61so10452120wes.1
        for <netdev@vger.kernel.org>; Tue, 15 Apr 2014 21:29:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Can someone explain to me, why would a driver choose to implement
Lockless TX? What are the advantages/disadvantages of choosing to do
so?Any performance benefits? A reference to a sample driver
implementation would be helpful to understand.

Thanks
Sharat
