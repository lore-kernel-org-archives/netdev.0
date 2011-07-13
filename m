From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 0/7] tg3: Formalize power source switching
Date: Wed, 13 Jul 2011 12:27:26 -0700
Message-ID: <1310585253-4817-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1744 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750891Ab1GMT2D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2011 15:28:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches make power source switching a more formal and carefully controlled process.


