From: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>
Subject: Re: [PATCH 0/2] net: Consider fragmentation of udp tunneled skbs in
 'ip_finish_output_gso'
Date: Mon, 18 Jul 2016 15:08:11 +0300
Message-ID: <20160718150811.24fbf90c@pixies>
References: <1468842574-1243-1-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, shmulik.ladkani@gmail.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>
To: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:33193 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751396AbcGRMIQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 08:08:16 -0400
Received: by mail-wm0-f54.google.com with SMTP id r190so20410354wmr.0
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 05:08:16 -0700 (PDT)
In-Reply-To: <1468842574-1243-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the v3 of https://patchwork.ozlabs.org/patch/648790/
