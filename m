From: Santiago Leon <santil@linux.vnet.ibm.com>
Subject: [patch 00/21] ibmveth updates
Date: Fri, 03 Sep 2010 23:27:58 -0500
Message-ID: <20100904042758.2655.8093.sendpatchset@jupiter1-ltc-lp2.austin.ibm.com>
Cc: brking@linux.vnet.ibm.com,
	Santiago Leon <santil@linux.vnet.ibm.com>, anton@samba.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:46213 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736Ab0IDE21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 00:28:27 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o844OYoF018039
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:24:34 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id o844SQlw233398
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:28:26 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o844SPdN030916
	for <netdev@vger.kernel.org>; Fri, 3 Sep 2010 22:28:26 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here are a number of patches for the IBM Power virtual ethernet driver. They
include Anton's patches as well as Robert's patches.  Patches 1-10 contain
the significant changes, and patches 11-21 are style and formatting changes
to bring it more into line with Linux coding standards.
