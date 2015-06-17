From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: [Q] sk->sk_protinfo leftovers
Date: Wed, 17 Jun 2015 14:58:15 +0300
Message-ID: <CAOJe8K2Vr_79egjdQk=S_SdOcxOR4A0BTORN4ODPMpOwntHUWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: ralf@linux-mips.org, edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f46.google.com ([209.85.213.46]:34464 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753140AbbFQL6Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 07:58:16 -0400
Received: by yhnv31 with SMTP id v31so5777132yhn.1
        for <netdev@vger.kernel.org>; Wed, 17 Jun 2015 04:58:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've found the old thread about removing sk_protinfo member [0]. Back
in 2005 Ralf mentioned that the ax25 case is more complicated. Have
the things changed in the ax25 code since  that time?

Thanks!

[0]: http://oss.sgi.com/archives/netdev/2005-03/msg03095.html
