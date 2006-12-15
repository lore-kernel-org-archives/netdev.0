From: Arjan van de Ven <arjan@linux.intel.com>
Subject: [patch 00/14] E1000 bugfix series for 2.6.20
Date: Fri, 15 Dec 2006 10:28:27 +0100
Message-ID: <1166174907.3365.108.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from a222036.upc-a.chello.nl ([62.163.222.36]:47094 "EHLO
	laptopd505.fenrus.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751421AbWLOKAv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Dec 2006 05:00:51 -0500
Received: from laptopd505.fenrus.org (localhost.localdomain [127.0.0.1])
	by laptopd505.fenrus.org (8.13.8/8.13.8) with ESMTP id kBF9gfEn006122
	for <netdev@vger.kernel.org>; Fri, 15 Dec 2006 10:42:41 +0100
Received: (from arjan@localhost)
	by laptopd505.fenrus.org (8.13.8/8.13.8/Submit) id kBF9ge2O006121
	for netdev@vger.kernel.org; Fri, 15 Dec 2006 10:42:40 +0100
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

this patch series contains critical bugfixes to the e1000 driver for
2.6.20 (and 3 very low intrusive features that help in testing). Without
these patches e1000 is totally unusable on my test machine.

Greetings,
   Arjan van de Ven
