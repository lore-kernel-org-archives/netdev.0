From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [2.6 patch] the overdue eepro100 removal
Date: Sun, 01 Jul 2007 13:33:10 -0700
Message-ID: <46880F86.1070405@intel.com>
References: <20070701202139.GM10869@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, saw@saw.sw.com.sg
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:64878 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755381AbXGAUdR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Jul 2007 16:33:17 -0400
In-Reply-To: <20070701202139.GM10869@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> This patch contains the overdue removal of the eepro100 driver.


...

this needs to be resceduled for 2.6.24 (at least). We're hoping to merge the 
proposed changes (still being worked on) in .23. Milton Miller and David Acker 
are working on that.

Auke
