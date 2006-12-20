From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH] d80211: fix get_tsf call
Date: Wed, 20 Dec 2006 11:15:28 +0100
Message-ID: <20061220111528.61fc6ab9@griffin.suse.cz>
References: <1166601865.22609.1.camel@devlinux-hong>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:59344 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753905AbWLTKOi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Dec 2006 05:14:38 -0500
To: Hong Liu <hong.liu@intel.com>
In-Reply-To: <1166601865.22609.1.camel@devlinux-hong>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 20 Dec 2006 16:04:25 +0800, Hong Liu wrote:
> get_tsf passes the wrong pointer to driver.

Already fixed, see commit 0690925f2f99f6d43322ec8507eaabdcf1435c3c.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
