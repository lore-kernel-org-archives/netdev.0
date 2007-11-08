From: Matti Aarnio <matti.aarnio@zmailer.org>
Subject: No implementation of NETLINK_USERSOCK ?
Date: Thu, 8 Nov 2007 17:15:12 +0200
Message-ID: <20071108151512.GY6372@mea-ext.zmailer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from z2.cat.iki.fi ([212.16.98.133]:59309 "EHLO z2.cat.iki.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756118AbXKHPPR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Nov 2007 10:15:17 -0500
Received: (mea@mea-ext) by mail.zmailer.org id S3540067AbXKHPPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2007 17:15:12 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some 6 months ago I asked about a way to make network protocol
servers(s) that live in userspace, but whose application interface
still uses kernel socket calls.

I recall getting an answer that there is  NETLINK_USERSOCK for that
use.  I have tried to have a look into what NETLINK_USERSOCK
supplies to its users, but alas there appears to be no implementation
at all in existence.   Is it some sort of placeholder of things
to implement some day ?

/Matti Aarnio
