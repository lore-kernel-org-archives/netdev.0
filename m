From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 -next 2/3] include/linux: update xfrm.h
Date: Tue, 4 Mar 2014 17:03:29 -0800
Message-ID: <20140304170329.51de98ab@nehalam.linuxnetplumber.net>
References: <1393857367-15016-1-git-send-email-nicolas.dichtel@6wind.com>
	<1393857367-15016-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:52148 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754243AbaCEBDd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 20:03:33 -0500
Received: by mail-pd0-f173.google.com with SMTP id z10so312200pdj.32
        for <netdev@vger.kernel.org>; Tue, 04 Mar 2014 17:03:32 -0800 (PST)
In-Reply-To: <1393857367-15016-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  3 Mar 2014 15:36:06 +0100
Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:

> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---

Sigh. couldn't you have chosen another variable name.
As it is new kernel headers with old iproute2 source will break.
