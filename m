From: Joyce Yu - System Software <joyce.yu@oracle.com>
Subject: Steps to integrate new 40G Network driver to the kernel tree
Date: Fri, 15 Apr 2011 16:51:18 -0700
Message-ID: <4DA8D9F6.2070908@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:23479 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751747Ab1DOXwW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 19:52:22 -0400
Received: from rcsinet13.oracle.com (rcsinet13.oracle.com [148.87.113.125])
	by rcsinet10.oracle.com (Switch-3.4.2/Switch-3.4.2) with ESMTP id p3FNqKU5007944
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 15 Apr 2011 23:52:21 GMT
Received: from acsmt356.oracle.com (acsmt356.oracle.com [141.146.40.156])
	by rcsinet13.oracle.com (Switch-3.4.2/Switch-3.4.1) with ESMTP id p3FNqJmD015401
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 15 Apr 2011 23:52:19 GMT
Received: from abhmt021.oracle.com (abhmt021.oracle.com [141.146.116.30])
	by acsmt356.oracle.com (8.12.11.20060308/8.12.11) with ESMTP id p3FNpJHA006701
	for <netdev@vger.kernel.org>; Fri, 15 Apr 2011 18:51:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

We have a new 40G network Linux driver. What are the steps to integrate  
it to the kernel tree?

Thanks,
Joyce

