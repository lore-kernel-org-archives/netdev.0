From: Martin Michlmayr <tbm@cyrius.com>
Subject: Re: Netconsole and logging everything from /dev/console
Date: Sat, 17 Nov 2007 20:31:09 +0100
Message-ID: <20071117193109.GR23935@deprecation.cyrius.com>
References: <20071116174315.GA20401@deprecation.cyrius.com> <20071116185036.GH19691@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Satyam Sharma <satyam.sharma@gmail.com>, netdev@vger.kernel.org,
	hpa@zytor.com
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sorrow.cyrius.com ([65.19.161.204]:3756 "EHLO sorrow.cyrius.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755546AbXKQTb2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Nov 2007 14:31:28 -0500
Content-Disposition: inline
In-Reply-To: <20071116185036.GH19691@waste.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Matt Mackall <mpm@selenic.com> [2007-11-16 12:50]:
> > Do you think that would be possible?
> 
> It is, definitely, you just need to wire up a tty struct's write
> method to netconsole's and add it to the console registration. But I
> haven't had any time to work on this in a while.

Where would I look for examples I could follow?
-- 
Martin Michlmayr
http://www.cyrius.com/
