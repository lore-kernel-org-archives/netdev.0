From: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Subject: wrt Age Entry For IPv4 & IPv6 Route Table
Date: Fri, 07 Sep 2007 11:01:45 +0530
Message-ID: <46E0E241.4000101@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Varun Chandramohan <varuncha@in.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:45218 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751934AbXIGFas (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Sep 2007 01:30:48 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l875Ul7i000891
	for <netdev@vger.kernel.org>; Fri, 7 Sep 2007 01:30:47 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l875UlV7690648
	for <netdev@vger.kernel.org>; Fri, 7 Sep 2007 01:30:47 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l875UkB7017916
	for <netdev@vger.kernel.org>; Fri, 7 Sep 2007 01:30:47 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

                  Last week i sent out the rev-3 of the age patch set,
and i got no comments . So i assume the people who reviewed it earlier
are ok with it. Can you please go through it and push it upstream?


Regards,
Varun
