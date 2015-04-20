From: Christ-Jan Wijtmans <cj.wijtmans@gmail.com>
Subject: Bug 61651 - [regression] Wake-on-LAN broken in alx (AR8161)
Date: Mon, 20 Apr 2015 21:12:04 +0200
Message-ID: <CAMjv+TQRJ9QLxi1iaFRfFPzaXVbGjn-JEzav+J6hWCRb7JuOdg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:34147 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752740AbbDTTMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2015 15:12:05 -0400
Received: by lbcga7 with SMTP id ga7so138569777lbc.1
        for <netdev@vger.kernel.org>; Mon, 20 Apr 2015 12:12:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Apologies if this is the wrong place or wrong format but since a while
multiple people want this functionality back into the ALX driver and
also claim that the reason for removing the functionality no longer
applies in new kernels. Also i believe that it could at least be made
an option in the .config file.

https://bugzilla.kernel.org/show_bug.cgi?id=61651

Live long and prosper,

Christ-Jan Wijtmans
