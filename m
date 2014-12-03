From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2] iproute2: Refactor: using new nl_msg struct for the
 all Netlink handlers
Date: Wed, 3 Dec 2014 09:23:58 -0800
Message-ID: <20141203092358.2a3c4239@urahara>
References: <1409913328-9003-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:39713 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750730AbaLCRYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 12:24:09 -0500
Received: by mail-pd0-f176.google.com with SMTP id y10so15815598pdj.21
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 09:24:08 -0800 (PST)
In-Reply-To: <1409913328-9003-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  5 Sep 2014 13:35:28 +0300
Vadim Kochan <vadim4j@gmail.com> wrote:

> It will easy to extend with new parameters in future.
> 
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>

This is a big change and not needed yet. Please hold off refactoring until the
new parameters are actually needed.
