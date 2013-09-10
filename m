From: Fernando Gont <fgont@si6networks.com>
Subject: Update to RFC793's TCP sequence number validation checks
Date: Tue, 10 Sep 2013 08:00:19 -0300
Message-ID: <522EFBC3.7030401@si6networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web01.jbserver.net ([93.186.182.34]:44465 "EHLO
	web01.jbserver.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751069Ab3IJL33 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Sep 2013 07:29:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Folks,

Dave Borman and me have posted an IETF Internet-Draft
(<http://tools.ietf.org/id/draft-gont-tcpm-tcp-seq-validation-01.txt>)
that fixes an existing bug in the RFC 793 TCP sequence number validation
checks.

The proposed fix has been implemented in open source stacks for many
years, so we're essentially updating the specs accordingly.

The IETF's TCPM working group chairs wanted to to some reviews of this
(very short) Internet-Draft before it is adopted as a working group item.

If you have a few minutes, please take a look, and post your
comments/review to <tcpm@ietf.org> (and make sure to CC me). This will
be of much help, and having feedback from the implementers' community
would be really valuable.

Thanks!

Best regards,
-- 
Fernando Gont
SI6 Networks
e-mail: fgont@si6networks.com
PGP Fingerprint: 6666 31C6 D484 63B2 8FB1 E3C4 AE25 0D55 1D4E 7492
