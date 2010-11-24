From: Jonas Bonn <jonas@southpole.se>
Subject: ethoc driver updates
Date: Wed, 24 Nov 2010 14:40:50 +0100
Message-ID: <1290606058-26703-1-git-send-email-jonas@southpole.se>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:38154 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754736Ab0KXOCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 09:02:49 -0500
Received: from needafix.southpole.se (needafix.southpole.se [192.168.16.197])
	by mail.southpole.se (Postfix) with ESMTPA id 2EB31480137
	for <netdev@vger.kernel.org>; Wed, 24 Nov 2010 14:41:00 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here's a set of patches that fix up some aspects of the ethoc network
driver:

i) device tree configuration
ii) reworked interrupt handling
iii) cleanups

This has been tested on an OpenRISC 1200 board; the OpenRISC Linux port
is using device trees now, hence the device tree bits.

/Jonas

