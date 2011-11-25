From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Netem man page
Date: Fri, 25 Nov 2011 14:47:55 +0100
Message-ID: <1322228876-10500-1-git-send-email-hagen@jauu.net>
Cc: Stephen Hemminger <shemminger@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:50051 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755414Ab1KYNsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2011 08:48:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netem man page attached. The patch describe the Correlated Loss Generator
extensions, which is kernel mainline but not supported by iproute yet (the
userland code is missing) - I decided to retain the CLG paragraphs.

If not, I can re-submit the man page reflecting the current state (without
CLG). After that I will send a patch to describe netem rate and cell extension.

Stephen?
