From: Jan Kiszka <jan.kiszka@web.de>
Subject: Re: [2.6 patch] the scheduled eepro100 removal
Date: Wed, 03 Jan 2007 10:10:50 +0100
Message-ID: <459B731A.301@web.de>
References: <20070102215726.GC20714@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, saw@saw.sw.com.sg,
	Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate01.web.de ([217.72.192.221]:49040 "EHLO
	fmmailgate01.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755005AbXACJKw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jan 2007 04:10:52 -0500
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20070102215726.GC20714@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> This patch contains the scheduled removal of the eepro100 driver.
> 

I'm sorry to disturb the schedule, but I'm not sure right now if this
pending issue of the e100 was meanwhile solved or declared a non-issue:

http://lkml.org/lkml/2006/9/8/105

Auke, can you confirm that it makes sense to re-test? IIRC, our private
thread ended without resolution after I discovered that the chip
revision makes the difference for me. Looked like it is either handled
incorrectly by e100 or screwed up on that board.

Jan
