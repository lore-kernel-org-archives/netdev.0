From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 5/7] d80211: indicate if unassociate/radio off status
Date: Thu, 21 Sep 2006 19:01:26 +0200
Message-ID: <20060921190126.4d884c44@logostar.upir.cz>
References: <44F356DF.9000000@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:8360 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751350AbWIURB2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2006 13:01:28 -0400
To: mabbas <mabbas@linux.intel.com>
In-Reply-To: <44F356DF.9000000@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 28 Aug 2006 13:49:35 -0700, mabbas wrote:
> This patch indicate unassociated and radio off status
> in name field

NAK.

Fix SIOCGIWAP handler instead.

 Jiri

-- 
Jiri Benc
SUSE Labs
