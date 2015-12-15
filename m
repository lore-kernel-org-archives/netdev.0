From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v6 2/4] net: diag: Add the ability to destroy a socket.
Date: Tue, 15 Dec 2015 09:44:51 -0800
Message-ID: <1450201491.8474.39.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151214.143739.879220917312503422.davem@davemloft.net>
	 <1450199868-93712-1-git-send-email-lorenzo@google.com>
	 <1450199868-93712-3-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	hannes@stressinduktion.org, ek@google.com, tom@herbertland.com,
	zenczykowski@gmail.com
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:35965 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932211AbbLORow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 12:44:52 -0500
Received: by mail-pf0-f174.google.com with SMTP id u66so8242743pfb.3
        for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 09:44:52 -0800 (PST)
In-Reply-To: <1450199868-93712-3-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-12-16 at 02:17 +0900, Lorenzo Colitti wrote:
> This adds a diag_destroy pointer to struct proto that allows a
> socket to be administratively closed without any action from the
> process owning the socket or the socket protocol.

> 
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>

Acked-by: Eric Dumazet <edumazet@google.com>
