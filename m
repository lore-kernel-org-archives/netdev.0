From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 1/6] tunnel: introduce udp_tun_rx_dst()
Date: Wed, 12 Aug 2015 09:44:31 -0700
Message-ID: <CAEP_g=81d1kfJnH3K7iZRsnjjyKT3JYDJKMcTUgqgtsY1DVuHA@mail.gmail.com>
References: <1439356653-21724-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:34709 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932168AbbHLQow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 12:44:52 -0400
Received: by labd1 with SMTP id d1so12432156lab.1
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 09:44:51 -0700 (PDT)
In-Reply-To: <1439356653-21724-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 11, 2015 at 10:17 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
> Introduce function udp_tun_rx_dst() to initialize tunnel dst on
> receive path.
>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Reviewed-by: Jesse Gross <jesse@nicira.com>
