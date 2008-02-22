From: "Stephens, Allan" <allan.stephens@windriver.com>
Subject: [PATCH 00/08] [TIPC]: Initial patch set for TIPC 1.6.3
Date: Fri, 22 Feb 2008 11:58:46 -0800
Message-ID: <AF1602CB2550CE4381C0C75118A7856B0246C88D@ala-mail02.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:37355 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932070AbYBVT70 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2008 14:59:26 -0500
Received: from ALA-MAIL03.corp.ad.wrs.com (ala-mail03 [147.11.57.144])
	by mail.wrs.com (8.13.6/8.13.6) with ESMTP id m1MJxOFs017775
	for <netdev@vger.kernel.org>; Fri, 22 Feb 2008 11:59:25 -0800 (PST)
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a patch set containing TIPC code developed as part of the TIPC
1.7
development project.  This first set contains small enhancements and bug
fixes
only, and is thus being integrated under the current TIPC 1.6
designation.

Patch set summary:
01 Update version to 1.6.3
02 Add argument validation for shutdown
03 Eliminate sparse warning in socket code
04 Minor cleanup of message header code
05 Use correct bitmask when setting version in
06 Enhancements to message header field writing
07 Removal of obsolete message header option co
08 TIPC network address handling cleanup

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
