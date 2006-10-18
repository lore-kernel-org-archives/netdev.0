From: Kumar Gala <galak@kernel.crashing.org>
Subject: BCM5461 phy issue in 10M/Full duplex
Date: Wed, 18 Oct 2006 08:57:21 -0500
Message-ID: <BD5AE82A-22F1-4813-A350-42532AB9A920@kernel.crashing.org>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nommos.sslcatacombnetworking.com ([67.18.224.114]:44298 "EHLO
	nommos.sslcatacombnetworking.com") by vger.kernel.org with ESMTP
	id S1161023AbWJRN5Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Oct 2006 09:57:24 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I was wondering if anyone has had any issues when trying to force a  
BCM5461 phy into 10M/full duplex.  I seem to be having an issue in  
the two managed switches I've tried this on but autoneg to 10/half.   
This causes a problem in that I start seeing a large number of frame  
errors.

I believe, but need to double check, that if I leave the BCM5461 in  
autoneg, and foce the switch to 10M/full that the BCM5461 will  
autoneg at 10M/half duplex.

Just wondering if anyone else has seen similar behavior with this PHY.

thanks

- kumar
