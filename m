From: Andrew Davidoff <davidoff@qedmf.net>
Subject: Intel igb module command line configuration in kernel sources
Date: Wed, 4 Sep 2013 22:51:50 -0400
Message-ID: <CAJLXCZRKdz-w8uR3ejzHrBot7OAyVJOWwzA0NszkZL16eFPTbQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:49941 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762415Ab3IECvu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 22:51:50 -0400
Received: by mail-pd0-f169.google.com with SMTP id r10so1182694pdi.28
        for <netdev@vger.kernel.org>; Wed, 04 Sep 2013 19:51:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I apologize that this is a user-type question but linux-net seems to
have gone away, and I cannot find a more appropriate networking
related mailing list.

Why are the Intel igb module configuration parameters, usually found
in igb_param.c and part of the source from Intel, not included in the
igb sources distributed with the linux kernel? I cannot find them in
the kernel's igb source, modinfo doesn't list them, and if I try to
use them as documented in the igb readme, I get errors because they
are unrecognized (ex: RSS). Am I overlooking an alternate
configuration method?

Thanks.
Andy
