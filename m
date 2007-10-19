From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 0/7] tg3: PCI error recovery and more
Date: Fri, 19 Oct 2007 14:36:32 -0700
Message-ID: <1192829793.22064.554.camel@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3016 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756161AbXJSVgq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2007 17:36:46 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset adds PCI error recovery, 5723 support and a few other odds
and ends.

