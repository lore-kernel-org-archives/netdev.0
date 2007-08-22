From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [ANNOUNCE] iproute2-2.6.23-rc3
Date: Wed, 22 Aug 2007 11:08:04 -0700
Message-ID: <20070822110804.30c2e803@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:53916 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1764370AbXHVSIl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 14:08:41 -0400
Received: from freepuppy.rosehill.hemminger.net (069-064-229-129.pdx.net [69.64.229.129])
	(authenticated bits=0)
	by smtp2.linux-foundation.org (8.13.5.20060308/8.13.5/Debian-3ubuntu1.1) with ESMTP id l7MI88n6026608
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 11:08:10 -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There have been a lot of changes for 2.6.23, so here is a test release
of iproute2 that should capture all the submitted patches


http://developer.osdl.org/shemminger/iproute2/download/iproute2-2.6.23-rc3.tar.gz

Johannes Berg (1):
      show multicast groups

PJ Waskiewicz (1):
      iproute2: sch_rr support in tc

Patrick McHardy (6):
      TC action parsing bug fix
      Bug fix tc action drop
      IPROUTE2: RTNETLINK nested attributes
      Use FRA_* attributes for routing rules
      iplink: use netlink for link configuration
      Fix meta ematch usage of 0 values

Pavel Emelianov (1):
      Make ip utility veth driver aware

Sridhar Samudrala (1):
      Fix bug  in display of ipv6 cloned/cached routes

Stephen Hemminger (3):
      Fix ss to handle partial records.
      sanitized headers update to 2.6.23-rc3
      Fix m_ipt build

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
