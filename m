From: Joseph Jezak <josejx@gentoo.org>
Subject: Re: [PATCH] bcm43xx: Fix code for spec changes of 2/7/2007
Date: Fri, 09 Feb 2007 14:05:03 -0500
Message-ID: <45CCC5DF.8010001@gentoo.org>
References: <45cca236.+lL/rsW3DbM3elnk%Larry.Finger@lwfinger.net> <200702091811.40683.mb@bu3sch.de> <45CCF432.2070002@gentoo.org> <200702091829.51002.mb@bu3sch.de> <45CCBB93.2040703@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	John Linville <linville@tuxdriver.com>,
	Bcm43xx-dev@lists.berlios.de
To: Larry Finger <larry.finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rwcrmhc14.comcast.net ([216.148.227.154]:45091 "EHLO
	rwcrmhc14.comcast.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946622AbXBITFK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Feb 2007 14:05:10 -0500
In-Reply-To: <45CCBB93.2040703@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I'll agree to that as long as there is a clear indication of any differences between V3 and V4 firmware.

That's also part of the problem.  With the v4 driver, Broadcom 
dropped support for a number of older BPHY devices (4301/4303 and 
some 4306 revisions).  Do we still want to support those?  Should I 
continue writing the specs for the uCode revision it's based on or 
should I combine them?

-Joe
