From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: XFRM messages explained?
Date: Mon, 16 Mar 2015 14:01:51 -0600
Message-ID: <550736AF.80500@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:32768 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932917AbbCPUNw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 16:13:52 -0400
Received: from eng-dhcp-123.vyatta.com (eng-dhcp-123.redfish-solutions.com [192.168.1.76])
	(authenticated bits=0)
	by mail.redfish-solutions.com (8.14.8/8.14.8) with ESMTP id t2GK1pOv005054
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 14:01:55 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

Is there a document (other than the kernel source) which documents the 
format of XFRM messages and how/when they are generated?

I need to write a program that looks at XFRM messages from the kernel 
(much the way that "ip xfrm monitor" does) and generates detailed 
logging based on the events.

Is there any document I could use?  Otherwise I'll have to grovel 
through the kernel source and sift through the calling orders, etc.

Thanks,

-Philip
