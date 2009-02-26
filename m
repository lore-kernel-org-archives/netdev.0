From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Kernel problem
Date: Thu, 26 Feb 2009 12:00:52 +0000
Message-ID: <20090226120052.GB5754@ff.dom.local>
References: <1FD907E1-25F5-4E3E-B58F-5596C2144A2E@sevsky.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denis Romanenko <ash@sevsky.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f176.google.com ([209.85.220.176]:32976 "EHLO
	mail-fx0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752312AbZBZMBA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 07:01:00 -0500
Received: by fxm24 with SMTP id 24so470602fxm.37
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2009 04:00:57 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1FD907E1-25F5-4E3E-B58F-5596C2144A2E@sevsky.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26-02-2009 12:24, Denis Romanenko wrote:
...
> hmm - for stabibility can i disable netconsole ? Or this bug is not  
> give my resutlts (reboot of router after 1-2 weeks of work )?

Yes, if you don't have to use this to track some more serious problem,
IMHO it's better to disable netconsole.

Jarek P.

PS: don't forget to "Reply All" next time ;-)
