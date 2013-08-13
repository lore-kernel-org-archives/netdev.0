From: "Ariel Elior" <ariele@broadcom.com>
Subject: RE: [PATCH net v5 0/5] bnx2x: fixes
Date: Tue, 13 Aug 2013 12:38:31 +0000
Message-ID: <6AE768456CEC4B4A9B2248CB6B87EB3E1BEB957E@SJEXCHMB05.corp.ad.broadcom.com>
References: <1376349903-3461-1-git-send-email-dmitry@broadcom.com>
 <20130813123043.GA30192@d2.synalogic.ca>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Benjamin Poirier" <benjamin.poirier@gmail.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3431 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756770Ab3HMMio convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 08:38:44 -0400
In-Reply-To: <20130813123043.GA30192@d2.synalogic.ca>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I'm confused. Wasn't "[PATCH net v4 1/6] bnx2x: properly initialize
> statistic counters" supposed to fix a race condition? According to
> earlier communication with Ariel:
> 	In this issue a race condition at driver startup causes a second
> 	statistics query to be sent before the first one completes,
> 	resulting in a firmware assert and a stuck chip. A patch was
> 	sent upstream fixing this:
> 	http://patchwork.ozlabs.org/patch/264810/

As I explicitly mentioned in the communique which you quoted above, the patch was sent but not yet accepted.
This is precisely the upstream process - patches are being sent, reviewed and sometimes rejected and revised.
If you have further questions please address them to me - the technical forum is no place for this kind of discussion.
Thanks,
Ariel
