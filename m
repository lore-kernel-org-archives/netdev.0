From: Josh Clark <jcinma@gmail.com>
Subject: Adding new packet scheduler
Date: Mon, 20 Oct 2014 13:32:19 -0400
Message-ID: <CAHmvzZQALDuwMPZC_ZncEP=BerniYis9Mx=oObUGNAY4wUGTZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:47360 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102AbaJTRdA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2014 13:33:00 -0400
Received: by mail-ie0-f173.google.com with SMTP id tp5so5207726ieb.18
        for <netdev@vger.kernel.org>; Mon, 20 Oct 2014 10:33:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi everyone,

I'm a student at NC State University, and I'm working on a project to
implement some new classful AQM algorithms and test their
effectiveness. However, I'm getting hung up on how to get the new
algorithm set up in the kernel.

>From what I've looked at, it looks like I need to add my code to
/net/sched/, and edit both the Kconfig and the Makefile to be able to
add my code as another module.

Finally, in order to use the new scheduler, I need to select it using
the tc command. What do I need to do to add my algorithm to the tc
command options?

Any insight, articles, READMEs, or criticism you have for me is welcome.

Thank you for all your help!




-Josh Clark
