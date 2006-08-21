From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [RFC] nl80211 + packet injection with it and d80211
Date: Mon, 21 Aug 2006 08:12:46 -0400
Message-ID: <20060821121239.GA30051@tuxdriver.com>
References: <1155824008.3491.7.camel@ux156> <1155912565.5671.1.camel@ux156> <1156142692.3669.11.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:1807 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1030412AbWHUMN4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2006 08:13:56 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1156142692.3669.11.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 21, 2006 at 08:44:52AM +0200, Johannes Berg wrote:
> Another thing that crossed my mind: Should we have a netlink call for
> adding virtual interfaces as well? Because then, the ipw2x00 drivers can
> have their monitor interface(s) added the same way.

Yes.

-- 
John W. Linville
linville@tuxdriver.com
