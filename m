From: Dan Smith <danms@us.ibm.com>
Subject: Socket C/R additional features
Date: Mon, 24 Aug 2009 10:28:01 -0700
Message-ID: <1251134884-24491-1-git-send-email-danms@us.ibm.com>
Cc: orenl@librato.com, netdev@vger.kernel.org
To: containers@lists.osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw0.danplanet.com ([71.245.107.82]:44144 "EHLO
	mail.danplanet.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752927AbZHXRZD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2009 13:25:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set fixes the missing "goto out" as identified by Serge in the last
patch and attaches acks from Dave and Serge where appropriate.

