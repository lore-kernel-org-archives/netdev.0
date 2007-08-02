From: Chuck Ebbert <cebbert@redhat.com>
Subject: include/linux/netfilter/xt_statistic.h isn't installed?
Date: Thu, 02 Aug 2007 17:50:12 -0400
Message-ID: <46B25194.1050408@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:49469 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751886AbXHBVuP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Aug 2007 17:50:15 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l72LoD6t011199
	for <netdev@vger.kernel.org>; Thu, 2 Aug 2007 17:50:13 -0400
Received: from mail.boston.redhat.com (mail.boston.redhat.com [172.16.76.12])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l72LoCin029715
	for <netdev@vger.kernel.org>; Thu, 2 Aug 2007 17:50:13 -0400
Received: from [172.16.83.145] (dhcp83-145.boston.redhat.com [172.16.83.145])
	by mail.boston.redhat.com (8.13.1/8.13.1) with ESMTP id l72LoCZp028116
	for <netdev@vger.kernel.org>; Thu, 2 Aug 2007 17:50:12 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Apparently xt_statistic.h needs to be added to
include/linux/netfilter/Kbuild for iptables 1.3.6 to build.

