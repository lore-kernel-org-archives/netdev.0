From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 00/17] sky2 update for 2.6.22
Date: Tue, 08 May 2007 20:49:49 -0700
Message-ID: <20070509034949.624934448@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:47370 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1033297AbXEIEE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 00:04:27 -0400
Cc: Greg KH <greg@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patches are against netdev-2.6 upstream code branch.

This includes a several bug fixes, and code cleanup to use standard
functions. There are a couple of PCI changes. One bug fix, and moving
common code in PCI base.

--

