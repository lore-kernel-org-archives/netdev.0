From: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Subject: Re: ps3 gelic network driver doesn't restart properly
Date: Mon, 27 Aug 2007 14:12:54 +0900
Message-ID: <20070827140347.C2A8.MOKUNO@sm.sony.co.jp>
References: <46CBFF3E.2080400@suse.de> <fc94aae90708221812w60ba7c30rf2669ae74401ee22@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "Stefan Assmann" <sassmann@suse.de>,
	Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>,
	netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org, ppc@suse.de
To: "Michael Lothian" <mike@fireburn.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MGW2.Sony.CO.JP ([137.153.0.14]:59448 "EHLO mgw2.sony.co.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751008AbXH0FM6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Aug 2007 01:12:58 -0400
In-Reply-To: <fc94aae90708221812w60ba7c30rf2669ae74401ee22@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry for late reply.  I was on holiday last week.

On Thu, 23 Aug 2007 02:12:47 +0100
"Michael Lothian" <mike@fireburn.co.uk> wrote:

> I can confirm this behaviour
> 
> It could also be worth mentioning I'm using gcc 4.2.1
> 
> Cheers


I also reproduced the symptom now.  I'll investigate.
Thanks, Stefan and Mike.

--
Masakazu MOKUNO

