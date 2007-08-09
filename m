From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 0/1] lro: Generic Large Receive Offload for TCP traffic
Date: Thu, 09 Aug 2007 02:31:11 -0400
Message-ID: <46BAB4AF.7010001@garzik.org>
References: <200708031441.14780.ossthema@de.ibm.com> <20070808.231144.22645124.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ossthema@de.ibm.com, raisch@de.ibm.com, themann@de.ibm.com,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	meder@de.ibm.com, tklein@de.ibm.com, gallatin@myri.com,
	stefan.roscher@de.ibm.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55914 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759068AbXHIGbS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 02:31:18 -0400
In-Reply-To: <20070808.231144.22645124.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Jan-Bernd Themann <ossthema@de.ibm.com>
> Date: Fri, 3 Aug 2007 14:41:14 +0200
> 
>> I think this patch could be the final version for now. It has been tested
>> on two platforms (power and x86_64) and works very well.
> 
> I checked in the LRO patch and the two sample driver ports
> to net-2.6.24, thanks!

Good to hear, thanks all.

I'll ponder whether I want to rebase netdev-2.6.git#upstream (2.6.24 
queue) on top of net-2.6.24.  I might put it off until the pain 
threshold rises, or I might go ahead and do it.  Undecided.

Either way, I'll want you to push to Linus before I do, when the next 
merge window opens.

	Jeff



