From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 0/6] sky2: v1.13 patches
Date: Thu, 15 Feb 2007 16:40:29 -0800
Message-ID: <20070216004028.943889000@linux-foundation.org>
Cc: netdev@vger.kernel.org, sk-drivers@lists.linux-foundation.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:40571 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422926AbXBPAnT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Feb 2007 19:43:19 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This set of patches fixes all the problems observed so far on
my machines. The biggest one was not doing transmit flow control
correctly.

--
Stephen Hemminger <shemminger@linux-foundation.org>

