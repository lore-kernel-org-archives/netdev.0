From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 0/5] tg3: Add 5761 support
Date: Wed, 10 Oct 2007 17:45:16 -0700
Message-ID: <1192063518.4878.182.camel@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3275 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757080AbXJKApd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2007 20:45:33 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following patchset adds support for the 5761 device and enables WOL
by default if out-of-box WOL is enabled in the NVRAM.  The 5761 patches
were tested against preproduction hardware.

