From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 0/7] sky2: patches for 2.6.22
Date: Thu, 24 May 2007 15:22:42 -0700
Message-ID: <20070524222242.555399884@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([207.189.120.13]:43007 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752729AbXEXWaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 18:30:30 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following are non-critical fixes found during review
of code. I don't expect them to fix the outstanding bugzilla
or mailing list problem reports. Mostly they are of the form,
"don't touch bits that aren't used on that chip".

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

