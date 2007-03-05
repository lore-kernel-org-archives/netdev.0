From: "Venkat Yekkirala" <vyekkirala@trustedcs.com>
Subject: RE: [PATCH] xfrm_policy delete security check misplaced
Date: Mon, 5 Mar 2007 09:36:01 -0600
Message-ID: <001401c75f3b$fb9da3f0$cc0a010a@tcssec.com>
Reply-To: <vyekkirala@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <jamesm@namei.org>,
	<cxzhang@watson.ibm.com>, <sds@tycho.nsa.gov>,
	<latten@austin.ibm.com>
To: "Venkat Yekkirala" <vyekkirala@tcsfw4.tcs-sec.com>,
	"'Eric Paris'" <eparis@parisplace.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:17213 "EHLO
	tcsfw4.tcs-sec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933523AbXCEPgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2007 10:36:39 -0500
In-Reply-To: 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Also, [Joy cc'd] deletions here needn't be audited?

OK, I see the next patch addressed this :)
