From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [RFC] iproute2: split up ip man page?
Date: Fri, 23 Dec 2011 01:10:03 +0100
Message-ID: <20111223001003.GD4767@hell>
References: <20111207131514.6815f813@nehalam.linuxnetplumber.net>
 <20111222103723.59a035df@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:43547 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752209Ab1LWAKH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2011 19:10:07 -0500
Content-Disposition: inline
In-Reply-To: <20111222103723.59a035df@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Stephen Hemminger | 2011-12-22 10:37:23 [-0800]:

>Ok, the ip man page is now broken up. I tried to fix some of the
>incorrect grammar and usage as well. The pages still need editing for
>readability.

Great! Commit 1b1177ed5f3 synched kernel headers. Should I rebase my iproute
netem rate patch (and again update include/linux/pkt_sched.h for net-next) or
keep you aware of this?

Hagen
