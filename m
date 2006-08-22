From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 12/18] d80211:  fix some sparse warnings
Date: Tue, 22 Aug 2006 20:55:28 +0200
Message-ID: <20060822205528.48b12358@griffin.suse.cz>
References: <20060821074107.648561364@sipsolutions.net>
	<20060821075201.370802472@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:63165 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1750787AbWHVSza (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2006 14:55:30 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <20060821075201.370802472@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 21 Aug 2006 09:41:19 +0200, Johannes Berg wrote:
> This patch fixes some warnings from sparse in d80211. Also
> fixes indentation in places near where the changes were.

I can't say I like those nearby indentation fixes at this time, but
I can live with it :-)

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
