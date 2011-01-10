From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 0/3] net: add device groups
Date: Mon, 10 Jan 2011 14:41:15 +0100
Message-ID: <1294666875.3583.6.camel@jlt3.sipsolutions.net>
References: <1294659524-22509-1-git-send-email-ddvlad@rosedu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, Octavian Purdila <opurdila@ixiacom.com>,
	netdev <netdev@vger.kernel.org>
To: Vlad Dogaru <ddvlad@rosedu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:56303 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753965Ab1AJNlT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 08:41:19 -0500
In-Reply-To: <1294659524-22509-1-git-send-email-ddvlad@rosedu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-01-10 at 13:38 +0200, Vlad Dogaru wrote:
> This patchset implements network device grouping and simple manipulation
> of groups. Netlink has been update to provide group information and
> means of applying changes to members of a specific group via a single
> message.

Can you explain the purpose of this? I'm wondering if it would make
sense to automatically group all virtual interfaces belonging to a
single 802.11 device, for instance.

johannes

