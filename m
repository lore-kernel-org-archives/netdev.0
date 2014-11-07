From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 iproute2 0/5] iproute2: Add FOU and GUE configuration
 in ip
Date: Thu, 6 Nov 2014 16:21:39 -0800
Message-ID: <20141106162139.37efcf3a@urahara>
References: <1415210788-8058-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:64083 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751209AbaKGAVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 19:21:50 -0500
Received: by mail-pa0-f42.google.com with SMTP id bj1so2339590pad.29
        for <netdev@vger.kernel.org>; Thu, 06 Nov 2014 16:21:50 -0800 (PST)
In-Reply-To: <1415210788-8058-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  5 Nov 2014 10:06:23 -0800
Tom Herbert <therbert@google.com> wrote:

> This patch set adds support in iproute2 to configure FOU and GUE ports
> for receive, and using FOU or GUE with ip tunnels (IPIP, GRE, sit) on
> transmit.

Applied 1-3 and 5 (ie not part 4) because those are the only ones
that apply to the current linux release.
