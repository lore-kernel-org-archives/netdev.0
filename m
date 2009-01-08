From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] hdlc: fix compile problem
Date: Thu, 08 Jan 2009 16:40:42 +0100
Message-ID: <m3vdsplsat.fsf@maximus.localdomain>
References: <20090107141343.3e256119@extreme>
	<m3d4eyvh28.fsf@maximus.localdomain> <20090107152858.6fb8ac5d@extreme>
	<m3tz8atxwv.fsf@maximus.localdomain> <20090107170842.6ee4eb77@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:41786 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751916AbZAHPko (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2009 10:40:44 -0500
In-Reply-To: <20090107170842.6ee4eb77@extreme> (Stephen Hemminger's message of "Wed\, 7 Jan 2009 17\:08\:42 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> The changes have to be applied to the 4 synclink drivers and to most
>> .c files in drivers/net/wan simultaneously, perhaps it's more practical
>> if I do it?

Ok, I will do.
-- 
Krzysztof Halasa
