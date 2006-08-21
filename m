From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 02/18] d80211:  master link
Date: Mon, 21 Aug 2006 21:08:18 +0200
Message-ID: <20060821210818.75a0f398@griffin.suse.cz>
References: <20060821074107.648561364@sipsolutions.net>
	<20060821075159.017613319@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:50907 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1750795AbWHUTIU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2006 15:08:20 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <20060821075159.017613319@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 21 Aug 2006 09:41:09 +0200, Johannes Berg wrote:
> This patch adds a link from the wiphy to the master device in sysfs.

Please add proper error handling and remove the link when the master
device is unregistered.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
