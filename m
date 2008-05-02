From: Nishant Kamat <nskamat@ti.com>
Subject: [PATCH 0/3] Adding support for OMAP LDP in smc911x driver
Date: Fri,  2 May 2008 07:52:12 -0500
Message-ID: <1209732735-24443-1-git-send-email-nskamat@ti.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:43645 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760627AbYEBMwh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 May 2008 08:52:37 -0400
Received: from dlep33.itg.ti.com ([157.170.170.112])
	by bear.ext.ti.com (8.13.7/8.13.7) with ESMTP id m42CqGvq008745
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 2 May 2008 07:52:26 -0500
Received: from legion.dal.design.ti.com (localhost [127.0.0.1])
	by dlep33.itg.ti.com (8.13.7/8.13.7) with ESMTP id m42CqG9B003841
	for <netdev@vger.kernel.org>; Fri, 2 May 2008 07:52:16 -0500 (CDT)
Received: from dirac.dal.design.ti.com (dirac.dal.design.ti.com [128.247.25.123])
	by legion.dal.design.ti.com (8.11.7p1+Sun/8.11.7) with ESMTP id m42CqFG07178
	for <netdev@vger.kernel.org>; Fri, 2 May 2008 07:52:15 -0500 (CDT)
Received: from dirac.dal.design.ti.com (localhost.localdomain [127.0.0.1])
	by dirac.dal.design.ti.com (8.12.11/8.12.11) with ESMTP id m42CqFT4000451
	for <netdev@vger.kernel.org>; Fri, 2 May 2008 07:52:15 -0500
Received: (from a0868510@localhost)
	by dirac.dal.design.ti.com (8.12.11/8.12.11/Submit) id m42CqF2f000443
	for netdev@vger.kernel.org; Fri, 2 May 2008 07:52:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

Following is a series of 3 patches to smc911x driver in order to:
	- support SMC9211 chipset in the same driver
	- fix a minor bug related to 'timeout' in case of hardware errors
	- support Texas Instruments' OMAP3430 based LDP or Zoom platform

Please consider for merging.

Thanks,
Nishant
