From: Jim Baxter <jim_baxter@mentor.com>
Subject: Difference between Net and Net-Next
Date: Wed, 27 Mar 2013 17:02:28 +0000 (UTC)
Message-ID: <loom.20130327T180118-245@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:50804 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751279Ab3C0RCq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Mar 2013 13:02:46 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UKtki-00024x-8c
	for netdev@vger.kernel.org; Wed, 27 Mar 2013 18:03:08 +0100
Received: from jimbax.plus.com ([81.174.248.107])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 27 Mar 2013 18:03:08 +0100
Received: from jim_baxter by jimbax.plus.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 27 Mar 2013 18:03:08 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

How do you decide which changes should go into "net" and which ones go into "net-
next"?

At a guess I would think bug fixes are in "net" and feature changes into
"net-next" but it is not obvious from the commit log.
