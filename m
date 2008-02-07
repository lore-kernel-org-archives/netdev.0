From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: converting fore200e driver to use request_firmware()
Date: Wed, 6 Feb 2008 19:01:50 -0500
Message-ID: <200802070001.m1701o8E019626@cmf.nrl.navy.mil>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:37756 "EHLO
	ginger.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764802AbYBGACi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 19:02:38 -0500
Received: from cmf.nrl.navy.mil (thirdoffive.cmf.nrl.navy.mil [134.207.12.180])
	by ginger.cmf.nrl.navy.mil (8.12.11.20060308/8.12.11) with ESMTP id m1701qhu024748
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 19:01:52 -0500 (EST)
Received: (from chas@localhost)
	by cmf.nrl.navy.mil (8.14.1/8.14.1/Submit) id m1701o8E019626
	for netdev@vger.kernel.org; Wed, 6 Feb 2008 19:01:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

however, i ran into a little problem with the sbus interface.  what should
i pass for 'struct device *' for an sbus device?
