From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH net] tcp: ipv6: Update MIB counters for drops
Date: Wed, 30 Jan 2013 18:18:09 -0800
Message-ID: <CAGK4HS-bR3BuV7N7pT1epsH9=fLXQrwZJm_ZAS0MNbb3=B=0Yg@mail.gmail.com>
References: <1359586683-16105-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, niveditasinghvi@gmail.com,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:36836 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751365Ab3AaCSK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 21:18:10 -0500
Received: by mail-ob0-f169.google.com with SMTP id ta14so2410408obb.14
        for <netdev@vger.kernel.org>; Wed, 30 Jan 2013 18:18:09 -0800 (PST)
In-Reply-To: <1359586683-16105-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30 January 2013 14:58, Vijay Subramanian <subramanian.vijay@gmail.com> wrote:
> This patch updates LINUX_MIB_LISTENDROPS and LINUX_MIB_LISTENOVERFLOWS in
> tcp_v6_conn_request() and tcp_v6_err(). tcp_v6_conn_request() in particular can
> drop SYNs for various reasons which are not currently tracked.
>
> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>


Please drop this too. I will send V2.


Thanks,
Vijay
