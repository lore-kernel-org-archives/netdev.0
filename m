From: "Berg, Johannes" <johannes.berg@intel.com>
Subject: RE: [WARNING] v3.12-rc6-3-g0df651a WARNING: CPU: 2 PID: 6800 at
 net/wireless/chan.c:373 cfg80211_chandef_usable+0x31/0x161 [cfg80211]()
Date: Mon, 21 Oct 2013 10:24:10 +0000
Message-ID: <1DC40B07CD6EC041A66726C271A73AE61AAE0910@IRSMSX102.ger.corp.intel.com>
References: <20131021102131.GA11265@glanzmann.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Thomas Glanzmann <thomas@glanzmann.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:42594 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753111Ab3JUKYW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 06:24:22 -0400
In-Reply-To: <20131021102131.GA11265@glanzmann.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Subject: [WARNING] v3.12-rc6-3-g0df651a WARNING: CPU: 2 PID: 6800 at
> net/wireless/chan.c:373 cfg80211_chandef_usable+0x31/0x161 [cfg80211]()
> 
> Hello,
> I'm referring to commit 9f5e8f6efc7c2601136b27d9c7325c245f8fd19a. I just

We have a fix in commit f478f33a93f9353dcd1fe55445343d76b1c3f84a I believe.

Johannes
-- 

Intel GmbH
Dornacher Strasse 1
85622 Feldkirchen/Muenchen, Deutschland
Sitz der Gesellschaft: Feldkirchen bei Muenchen
Geschaeftsfuehrer: Christian Lamprechter, Hannes Schwaderer, Douglas Lusk
Registergericht: Muenchen HRB 47456
Ust.-IdNr./VAT Registration No.: DE129385895
Citibank Frankfurt a.M. (BLZ 502 109 00) 600119052
