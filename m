From: David Miller <davem@davemloft.net>
Subject: Re: TCP-MD5 checksum failure on x86_64 SMP
Date: Fri, 07 May 2010 02:12:51 -0700 (PDT)
Message-ID: <20100507.021251.146344534.davem@davemloft.net>
References: <i2y571fb4001005060455m39bed7f7if5fcfc45b12bc4d3@mail.gmail.com>
	<1273147586.2357.63.camel@edumazet-laptop>
	<70125082-4A0B-4E54-A7F6-B6CDC0375E78@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, bhaskie@gmail.com, shemminger@vyatta.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org
To: lars.eggert@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58320
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750824Ab0EGJMp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 05:12:45 -0400
In-Reply-To: <70125082-4A0B-4E54-A7F6-B6CDC0375E78@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lars Eggert <lars.eggert@nokia.com>
Date: Fri, 7 May 2010 11:46:40 +0300

> You'll obviously still want TCP-MD5 support for talking to existing
> equipment, but significant cycles would IMO be better spent on
> TCP-AO.

Code we have and users use which is unstable and crashes is more
important to work on and fix than code we don't have which
user's therefore don't use.

You're wrong from just about every possible angle.

Whoever finds AO useful will work on it, just as was the case with MD5
support.  And right now, that "whoever" is definitely not us. :-)

