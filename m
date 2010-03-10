From: Frans Pop <elendil@planet.nl>
Subject: When best to submit patches with small changes in multiple files?
Date: Wed, 10 Mar 2010 04:49:12 +0100
Message-ID: <201003100449.12952.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpsmtpm-eml104.kpnxchange.com ([195.121.3.8]:63089 "EHLO
	CPSMTPM-EML104.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756028Ab0CJDtP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Mar 2010 22:49:15 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have patches prepared to remove trailing spaces from kernel messages 
for ./net and ./drivers/net (including wireless).

In total 15 patches with
   81 files changed, 351 insertions(+), 351 deletions(-)

When would be the best time to submit:
- now, to be included in .34
- now, for -next
- any time
- near beginning of merge window (rebased against netdev-next)
- not at all ;-)
?

Cheers,
FJP
