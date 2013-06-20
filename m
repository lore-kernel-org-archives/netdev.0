From: Arnaud Patard (Rtp) <arnaud.patard@rtp-net.org>
Subject: [patch 0/2] Fix system hang when loading mvneta module
Date: Fri, 21 Jun 2013 00:06:44 +0200
Message-ID: <20130620220644.715387300@rtp-net.org>
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lebrac.rtp-net.org ([88.191.135.105]:50540 "EHLO
	lebrac.rtp-net.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750807Ab3FVUZb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Jun 2013 16:25:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset aims at fixing a system hang when loading the mvneta module.
I'm not sure what's meaning of the magical value used in patch 2 but at least,
it's used in code from Marvell and make things work.

Regards,
Arnaud
