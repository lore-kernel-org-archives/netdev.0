From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [PATCH 0/3] [AF_IUCV/IUCV]: net-2.6.22 fixes
Date: Thu, 19 Apr 2007 11:10:52 +0200
Message-ID: <20070419091052.GB14586@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([195.212.29.136]:13143 "EHLO
	mtagate3.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993212AbXDSJKD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2007 05:10:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,
following three patches contain fixes for AF_IUCV socket support and
for iucv, the base code for IUCV related actions in z/VM .
I made these patches against net-2.6.22, 
but they should also apply to net-2.6 without any conflicts.
Well it works on my copy :-). 
I will make another patchset for net-2.6 if you want me to do so. 

Thank you.

Frank
