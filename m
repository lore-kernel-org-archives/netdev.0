From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next] netlink: cleanup tap related functions
Date: Mon, 30 Dec 2013 19:58:13 +0100
Message-ID: <1388429893.4410.2.camel@jlt4.sipsolutions.net>
References: <20131230104922.7b16965e@nehalam.linuxnetplumber.net>
	 (sfid-20131230_194927_750768_E6A7ED25)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:43538 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932069Ab3L3S6V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Dec 2013 13:58:21 -0500
In-Reply-To: <20131230104922.7b16965e@nehalam.linuxnetplumber.net> (sfid-20131230_194927_750768_E6A7ED25)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-12-30 at 10:49 -0800, Stephen Hemminger wrote:
> Cleanups in netlink_tap code
>  * remove unused function netlink_clear_multicast_users
>  * make local function static
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Looks good to me.

Reviewed-by: Johannes Berg <johannes@sipsolutions.net>

johannes
