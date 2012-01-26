From: "Ariel Elior" <ariele@broadcom.com>
Subject: [PATCH 0/10] bnx2x: Physical Device Assignment patch series
Date: Thu, 26 Jan 2012 18:01:44 +0200
Message-ID: <1327593714-18358-1-git-send-email-ariele@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Ariel Elior" <ariele@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4223 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751720Ab2AZQBq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jan 2012 11:01:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

In this series,

Patch number 1 Introduces support for multiple traffic classes for the 5771xx hardware.
Patches 2 through 9 Allow using the bnx2x driver in environments supporting Physical Device Assignment.
Patch 10 Updates the version to 1.72.0 and advances the copyright to include 2012.

Please consider applying,
Thanks,
Ariel
