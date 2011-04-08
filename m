From: Pallai Roland <pallair@magex.hu>
Subject: Re: Kernel panic when using bridge
Date: Fri, 8 Apr 2011 21:12:59 +0200
Message-ID: <BANLkTi=bk8uGAxwXUNh5h9HN0T-W2ruaYw@mail.gmail.com>
References: <4D9E62D9.5010400@scotdoyle.com>
	<loom.20110408T153726-822@post.gmane.org>
	<4D9F2248.90300@scotdoyle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Sebastian Nickel <Sebastian.Nickel@hetzner.de>,
	netdev@vger.kernel.org
To: Scot Doyle <lkml@scotdoyle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:62748 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757719Ab1DHTNB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2011 15:13:01 -0400
Received: by bwz15 with SMTP id 15so3075586bwz.19
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2011 12:13:00 -0700 (PDT)
In-Reply-To: <4D9F2248.90300@scotdoyle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/4/8 Scot Doyle <lkml@scotdoyle.com>:
> Perhaps the problem is isolated to the bridging code? Neither KVM guest nor
> associated tap device were running during my second reported panic.
> Here's a similar stacktrace from a third person:
> http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=620201
Yep, I'm the third person. :)

What I can tell you my servers are stable after bridging has been eliminated.
