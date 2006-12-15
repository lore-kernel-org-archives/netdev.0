From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [PATCH 1/6] d80211: add IEEE802.11e/WMM MLMEs, Status Code and
	Reason Code
Date: Fri, 15 Dec 2006 11:18:53 +0800
Message-ID: <1166152733.2929.89.camel@debian.sh.intel.com>
References: <20061214040204.GA10643@mail.intel.com>
	 <20061214112704.1442a344@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Michael Wu <flamingice@sourmilk.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:30760 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751640AbWLODVQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Dec 2006 22:21:16 -0500
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20061214112704.1442a344@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-12-14 at 11:27 +0100, Jiri Benc wrote:
> On Thu, 14 Dec 2006 12:02:04 +0800, Zhu Yi wrote:
> > Signed-off-by: Zhu Yi <yi.zhu@intel.com>
> 
> Please Cc: me and John Linville on d80211 patches otherwise your
> chances of review (and inclusion) are much lower.
> 
> In addition to comments from Michael (which are all perfectly valid and
> you need to address all of them):
> 
> > +struct ieee802_11_ts_info {
> 
> Choose a name consistent with the rest of the header (e.g. ieee80211_
> prefix).

OK.

Thanks,
-yi
