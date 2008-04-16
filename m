From: Arjan van de Ven <arjan@linux.intel.com>
Subject: followup on tcp_ack warnings
Date: Tue, 15 Apr 2008 21:45:06 -0700
Message-ID: <48058452.5050207@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:30867 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755678AbYDPEpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2008 00:45:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

the tcp_ack (and related) warnings basically have fallen out of the reports from the last week,
so it seems these actually got fixed....

I'll let the list know if they show up again in the future.
