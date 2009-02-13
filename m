From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Kernel crash on htbinit restart
Date: Fri, 13 Feb 2009 23:16:55 +0100
Message-ID: <20090213221655.GA3262@ami.dom.local>
References: <334525CB-A895-4320-BF30-B223652806F8@sevsky.net> <20090213210954.GC2929@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denis Romanenko <ash@sevsky.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f161.google.com ([209.85.218.161]:39376 "EHLO
	mail-bw0-f161.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753312AbZBMWPH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2009 17:15:07 -0500
Received: by bwz5 with SMTP id 5so2044197bwz.13
        for <netdev@vger.kernel.org>; Fri, 13 Feb 2009 14:15:04 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20090213210954.GC2929@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 13, 2009 at 10:09:54PM +0100, Jarek Poplawski wrote:
...
> Otherwise there were nothing critical around this.

Actually, there was later fixed a issue in gen_estimator, but this
could matter only if you delete a large number (many thousands) of
HTB classes.

Jarek P.
