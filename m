From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC PATCH 1/2] net: Add support for hardware-offloaded
 encapsulation
Date: Fri, 26 Oct 2012 13:21:04 -0700
Message-ID: <20121026132104.028a149f@nehalam.linuxnetplumber.net>
References: <1351189753-5912-1-git-send-email-joseph.gasparakis@intel.com>
	<1351189753-5912-2-git-send-email-joseph.gasparakis@intel.com>
	<20121025141656.5383dabe@nehalam.linuxnetplumber.net>
	<1351203635.2662.73.camel@bwh-desktop.uk.solarflarecom.com>
	<F9D617782E85934FB0AD6CD1BA0C8EE7324B7663@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"chrisw@sous-sol.org" <chrisw@sous-sol.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
To: "Gasparakis, Joseph" <joseph.gasparakis@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40286 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966367Ab2JZUV6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2012 16:21:58 -0400
In-Reply-To: <F9D617782E85934FB0AD6CD1BA0C8EE7324B7663@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 26 Oct 2012 19:54:12 +0000
"Gasparakis, Joseph" <joseph.gasparakis@intel.com> wrote:

> Stephen, are you happy with Ben's comment?
> If that is the case I would prefer to keep the patch as is as I believe it makes sense to group the features that way.

No problem. As long as it's safe which Ben said.
