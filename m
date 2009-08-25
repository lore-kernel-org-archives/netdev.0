From: Sridhar Samudrala <sri@us.ibm.com>
Subject: why is IP_MAX_MTU limited to 65520 bytes
Date: Tue, 25 Aug 2009 16:25:40 -0700
Message-ID: <1251242740.3169.69.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:33001 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932255AbZHYXZl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 19:25:41 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e39.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n7PNKbiG001414
	for <netdev@vger.kernel.org>; Tue, 25 Aug 2009 17:20:37 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7PNPgdw217036
	for <netdev@vger.kernel.org>; Tue, 25 Aug 2009 17:25:42 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7PNPgSj030547
	for <netdev@vger.kernel.org>; Tue, 25 Aug 2009 17:25:42 -0600
Received: from [9.47.18.19] (w-sridhar.beaverton.ibm.com [9.47.18.19])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id n7PNPfK2030517
	for <netdev@vger.kernel.org>; Tue, 25 Aug 2009 17:25:42 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Any reason why the maximum IP payload is limited to IP_MAX_MTU(0xFFF0) bytes
instead of the maximum possible value of 0xFFFF

Thanks
Sridhar

