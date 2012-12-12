From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute2 1/3] ip: add support of netconf messages
Date: Wed, 12 Dec 2012 08:59:59 -0800
Message-ID: <20121212085959.31d8cd79@nehalam.linuxnetplumber.net>
References: <1355305907-7102-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49740 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753920Ab2LLRBO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2012 12:01:14 -0500
In-Reply-To: <1355305907-7102-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok, but the headers for all of iproute2 are supposed to come from
sanitized kernel headers from "make headers_install"

You missed that piece in the original patch.
