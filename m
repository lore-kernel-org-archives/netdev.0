From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 0/13] tg3: 5761, 5784, and 5764 support fixes
Date: Fri, 09 Nov 2007 16:38:34 -0800
Message-ID: <1194655114.5745.262.camel@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3312 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751814AbXKJAjO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Nov 2007 19:39:14 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following patches round out support for 5784, 5764, and 5761
devices, fixing bugs in the process.

