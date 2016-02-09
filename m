From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v2 01/21] iplink: bridge: export bridge_id and
 designated_root
Date: Tue, 9 Feb 2016 09:25:37 -0800
Message-ID: <20160209092537.0ee2cca0@xeon-e3>
References: <1454973279-9170-1-git-send-email-razor@blackwall.org>
	<1454973279-9170-2-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:32856 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755901AbcBIRZZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 12:25:25 -0500
Received: by mail-pa0-f41.google.com with SMTP id cy9so94487224pac.0
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2016 09:25:25 -0800 (PST)
In-Reply-To: <1454973279-9170-2-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  9 Feb 2016 00:14:19 +0100
Nikolay Aleksandrov <razor@blackwall.org> wrote:

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> Netlink returns the bridge_id and designated_root, we just need to
> make them visible.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Series applied.
