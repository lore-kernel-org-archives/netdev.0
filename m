From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [2.6.25 patch] the planned eepro100 removal
Date: Thu, 25 Oct 2007 18:36:23 -0400
Message-ID: <47211A67.2090201@pobox.com>
References: <20071024162440.GN30533@stusta.de> <4720FFAA.9080709@tmr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@kernel.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, saw@saw.sw.com.sg,
	"Kok, Auke" <auke-jan.h.kok@intel.com>
To: Bill Davidsen <davidsen@tmr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55470 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754858AbXJYWg3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2007 18:36:29 -0400
In-Reply-To: <4720FFAA.9080709@tmr.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bill Davidsen wrote:
> Adrian Bunk wrote:
>> This patch contains the planned removal of the eepro100 driver.
>>
> Are the e100 people satisfied that e100 now handles all known cases? I 

Nope.  There are still e100 work outstanding that means we cannot kill 
eepro100.

	Jeff


