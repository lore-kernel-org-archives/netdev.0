From: Dan Smith <danms@us.ibm.com>
Subject: Socket C/R additional features
Date: Tue, 18 Aug 2009 12:57:12 -0700
Message-ID: <1250625435-16299-1-git-send-email-danms@us.ibm.com>
Cc: containers@lists.osdl.org, netdev@vger.kernel.org
To: orenl@librato.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw0.danplanet.com ([71.245.107.82]:34968 "EHLO
	mail.danplanet.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750886AbZHRTyk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2009 15:54:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an updated version of my previous patch set, with the fourth patch
removed.  This is rebased on current v17-dev and includes Serge's
recommended changes to may_setgid().

