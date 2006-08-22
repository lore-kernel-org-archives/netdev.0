From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [PATCH 4/7] ieee80211: Add IEEE80211_API_VERSION macro
Date: Tue, 22 Aug 2006 12:50:29 +0800
Message-ID: <1156222229.17642.349.camel@debian.sh.intel.com>
References: <20060821033322.GA4793@mail.intel.com>
	 <1156156799.5729.23.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:28004 "EHLO
	orsmga101-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S1751296AbWHVEw2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 00:52:28 -0400
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1156156799.5729.23.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-08-21 at 06:39 -0400, Dan Williams wrote:
> Per my other mail, what exactly has changed and must be checked?  The
> SIOCGIWFREQ stuff?

The prototype of ieee80211_tx_frame() changed. It used to have 3
parameters. Now it has 5.

Thanks,
-yi
