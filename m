From: ranjith kumar <ranjithproxy@gmail.com>
Subject: (unknown)
Date: Sat, 8 Sep 2012 19:43:02 +0530
Message-ID: <CAG9fbzbQg9vWgt6ZcaRYKUQJNzQEziFp6_3Q_cJtSthsjhbN2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:55451 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751975Ab2IHOND (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Sep 2012 10:13:03 -0400
Received: by wibhr14 with SMTP id hr14so501903wib.1
        for <netdev@vger.kernel.org>; Sat, 08 Sep 2012 07:13:02 -0700 (PDT)
Subject: 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

We know that, in TCP socket programming accept() is a "blocking call".
Is  there any alternative to make "unblocked" accept() call?

I want to this because I am unable to kill the thread which made call
to accept().
Thanks.
