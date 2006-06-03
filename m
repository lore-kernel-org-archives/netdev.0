From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [RFC ] [1 of 4] IEEE802.11 Regulatory/Geographical Support for drivers - statement of project
Date: Sun, 4 Jun 2006 01:12:01 +0200
Message-ID: <200606040112.01684.mb@bu3sch.de>
References: <448210EF.10103@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:9674
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751437AbWFCXMJ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Jun 2006 19:12:09 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <448210EF.10103@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 04 June 2006 00:45, Larry Finger wrote:
>    b) It then creates a new directory, '/proc/net/ieee80211_geo', and populates it with 2 files for 
> communication with the daemon. The first, which is read by the daemon, contains the country and 
> outdoor codes, and the second is for the the daemon to write the 'struct ieee80211_geo' data 
> corresponding to the country and indoor/outdoor information passed from the kernel.

Use sysfs, please.

-- 
Greetings Michael.
