From: Arnaud Patard (Rtp) <arnaud.patard@rtp-net.org>
Subject: [patch v2 0/2] Fix system hang when loading mvneta module - take 2
Date: Mon, 29 Jul 2013 21:56:46 +0200
Message-ID: <20130729195646.433524957@rtp-net.org>
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lebrac.rtp-net.org ([88.191.135.105]:53116 "EHLO
	lebrac.rtp-net.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752049Ab3G2UDt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jul 2013 16:03:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This is a second version of my patchset to fix mvneta as module.
I've addressed previous comments. I've also fixed probe
error path which was broken in the previous version.

Arnaud
