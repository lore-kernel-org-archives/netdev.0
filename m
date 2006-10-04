From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] wext
Date: Wed, 04 Oct 2006 10:37:23 +0200
Message-ID: <1159951043.2817.36.camel@ux156>
References: <200610021955.23112.chunkeey@web.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:61114 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1030675AbWJDIga
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Oct 2006 04:36:30 -0400
To: chunkeey@web.de
In-Reply-To: <200610021955.23112.chunkeey@web.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-10-02 at 19:55 +0200, chunkeey@web.de wrote:
> This patch (wext-patch) is a proposal. It adds two new defines for the 
> SIOCSIWMLME to cover all kinds MLMEs (well, except REASSOC) through a ioctl.
> (it would be nice to have them, so that I can post the hostapd code for the 
> prism54 card!)

NACK from me. Please help me work on nl80211 instead :)

johannes
