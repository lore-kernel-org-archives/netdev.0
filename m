From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] geneve: add support for IPv6 link partners
Date: Mon, 23 Nov 2015 16:23:44 -0800
Message-ID: <20151123162344.4bcdd4cb@xeon-e3>
References: <1443119682-14236-1-git-send-email-linville@tuxdriver.com>
	<1443119979-14479-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>, davem@davemloft.net
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35247 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751831AbbKXAYQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 19:24:16 -0500
Received: by pacej9 with SMTP id ej9so1234649pac.2
        for <netdev@vger.kernel.org>; Mon, 23 Nov 2015 16:24:16 -0800 (PST)
In-Reply-To: <1443119979-14479-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Sep 2015 14:39:39 -0400
"John W. Linville" <linville@tuxdriver.com> wrote:

> Signed-off-by: John W. Linville <linville@tuxdriver.com>
> ---
>  include/linux/if_link.h |  1 +
>  ip/iplink_geneve.c      | 20 +++++++++++++-------
>  2 files changed, 14 insertions(+), 7 deletions(-)

Applied, the if_link.h change was already picked up.
