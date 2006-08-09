From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] pcnet32: break in 2.6.18-rc1 identified (corrected)
Date: Wed, 09 Aug 2006 00:01:34 -0400
Message-ID: <44D95E1E.9010403@garzik.org>
References: <20060804162628.GA7229@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: murrayma@citi.umich.edu, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59547 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1030346AbWHIEBk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 00:01:40 -0400
To: Don Fry <brazilnut@us.ibm.com>
In-Reply-To: <20060804162628.GA7229@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don Fry wrote:
> I noticed this morning that I had the polarity wrong in my patch
> yesterday for older chips in the pcnet32_suspend routine.  Here is the
> correct patch to test.
> 
>> A change I made for 2.6.17 and another for 2.6.18 do not work on older
>> pcnet32 chips which I do not have access to.  Please test this patch if
>> you have access to a 79C970, 79C974, or 79C965 (VLB) version of the
>> pcnet32 and let me know if it solves any problems.  I have tested with a
>> 79C970A, 79C971, 79C972, 79C973, 79C975, 79C976, and 79C978 and the
>> changes work as expected.

Did testing succeed?

signed-off-by?

	Jeff



