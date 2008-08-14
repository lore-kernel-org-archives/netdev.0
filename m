From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [PATCH 1/1] NET: e100, fix iomap read
Date: Thu, 14 Aug 2008 09:29:02 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F5205DEA1D6@orsmsx418.amr.corp.intel.com>
References: <1218731243-32732-1-git-send-email-jirislaby@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <e1000-devel@lists.sourceforge.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: "Jiri Slaby" <jirislaby@gmail.com>, <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:24103 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752467AbYHNQ3q convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 12:29:46 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1218731243-32732-1-git-send-email-jirislaby@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Slaby wrote:
> There were 2 omitted readb's used on an iomap space. eliminate them
> by using ioread8 instead.
> 
> Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Cc: Bruce Allan <bruce.w.allan@intel.com>
> Cc: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> Cc: John Ronciak <john.ronciak@intel.com>

Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
