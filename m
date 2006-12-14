From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 1/6] d80211: add IEEE802.11e/WMM MLMEs, Status Code and
 Reason Code
Date: Thu, 14 Dec 2006 11:27:04 +0100
Message-ID: <20061214112704.1442a344@griffin.suse.cz>
References: <20061214040204.GA10643@mail.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Michael Wu <flamingice@sourmilk.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:51513 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751905AbWLNK0k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Dec 2006 05:26:40 -0500
To: yi.zhu@intel.com
In-Reply-To: <20061214040204.GA10643@mail.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 14 Dec 2006 12:02:04 +0800, Zhu Yi wrote:
> Signed-off-by: Zhu Yi <yi.zhu@intel.com>

Please Cc: me and John Linville on d80211 patches otherwise your
chances of review (and inclusion) are much lower.

In addition to comments from Michael (which are all perfectly valid and
you need to address all of them):

> +struct ieee802_11_ts_info {

Choose a name consistent with the rest of the header (e.g. ieee80211_
prefix).

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
