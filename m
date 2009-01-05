From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 0/5] qlge:Fix sparse warnings.
Date: Mon, 5 Jan 2009 14:26:00 -0800
Message-ID: <20090105222600.GA4232@susedev.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org"@linux-7mw0.qlogic.com,
	"linux-driver@qlogic.com"@linux-7mw0.qlogic.com,
	"ron.mercer@qlogic.com"@linux-7mw0.qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:42041 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753936AbZAEW0F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2009 17:26:05 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

The attached patches fix sparse warnings as requested by Christoph
Hellwig.

I will get rid of the volatile usage per your request in my next series.

Thanks,
Ron
