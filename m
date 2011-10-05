From: Joyce Yu - System Software <joyce.yu@oracle.com>
Subject: A new 40G Network driver ready to submit to the kernel tree
Date: Wed, 05 Oct 2011 16:13:36 -0700
Message-ID: <4E8CE4A0.4060202@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:44069 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935480Ab1JEXNq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 19:13:46 -0400
Received: from rtcsinet21.oracle.com (rtcsinet21.oracle.com [66.248.204.29])
	by rcsinet15.oracle.com (Switch-3.4.4/Switch-3.4.4) with ESMTP id p95NDhev010677
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 5 Oct 2011 23:13:45 GMT
Received: from acsmt356.oracle.com (acsmt356.oracle.com [141.146.40.156])
	by rtcsinet21.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id p95NDgHB028714
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 5 Oct 2011 23:13:43 GMT
Received: from abhmt113.oracle.com (abhmt113.oracle.com [141.146.116.65])
	by acsmt356.oracle.com (8.12.11.20060308/8.12.11) with ESMTP id p95NDbA9010590
	for <netdev@vger.kernel.org>; Wed, 5 Oct 2011 18:13:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



I have a new 40G Network driver ready to submit to the kernel tree. The 
driver has been ported to latest linux-3.0-rc5 and net-2.6-353e5c9 tree. 
The driver versions for 2.6.18 and 2.6.32 based kernel have been fully 
tested and released to the customer. Shall I just send the driverxx.c 
and driverxx.h for net-2.6-353e5c9 and linux-3.0-rc5 to this alias?

Thanks,
Joyce
