From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [PATCH] ieee80211: WLAN_GET_SEQ_SEQ fix
Date: Tue, 19 Dec 2006 11:16:57 +0800
Message-ID: <1166498217.10342.49.camel@debian.sh.intel.com>
References: <20061218092613.GA27091@mail.intel.com>
	 <4586C6D1.5060607@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:1530 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752301AbWLSDTq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Dec 2006 22:19:46 -0500
To: Larry Finger <larry.finger@lwfinger.net>
In-Reply-To: <4586C6D1.5060607@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-12-18 at 10:50 -0600, Larry Finger wrote:
> 
> Shouldn't this fix have some commit message like "The
> WLAN_GET_SEQ_SEQ(seq) macro in ieee80211 is 
> selecting the wrong region."? That said, the fix conforms with the
> IEEE802.11 specs.
> 
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net> 

OK. I thought it was obvious.

Thanks,
-yi
