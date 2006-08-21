From: Thomas Glanzmann <sithglan@stud.uni-erlangen.de>
Subject: Re: sky2 doesn't receive any packages after I ssh in via ipv6 and edit a file in vim (reproducable)
Date: Tue, 22 Aug 2006 00:26:34 +0200
Message-ID: <20060821222634.GC21790@cip.informatik.uni-erlangen.de>
References: <20060821212243.GA1558@cip.informatik.uni-erlangen.de> <20060821150231.31a947d4@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from faui03.informatik.uni-erlangen.de ([131.188.30.103]:47015 "EHLO
	faui03.informatik.uni-erlangen.de") by vger.kernel.org with ESMTP
	id S1751251AbWHUW0g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 18:26:36 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060821150231.31a947d4@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

> Is this fix in your version?
> 	http://www.mail-archive.com/netdev@vger.kernel.org/msg18603.html

I put this one in and recompiled and I am *still* able to reproduce the
problem.

        Thomas
