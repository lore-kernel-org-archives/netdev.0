From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] bluetooth: cmtp: fix information leak to userland
Date: Tue, 02 Nov 2010 16:35:58 +0100
Message-ID: <1288712158.3322.179.camel@aeonflux>
References: <1288448787-5848-1-git-send-email-segooon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org,
	"Gustavo F. Padovan" <padovan@profusion.mobi>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Vasiliy Kulikov <segooon@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:36072 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751883Ab0KBPgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Nov 2010 11:36:16 -0400
In-Reply-To: <1288448787-5848-1-git-send-email-segooon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Vasiliy,

> Structure cmtp_conninfo is copied to userland with some padding fields
> unitialized.  It leads to leaking of contents of kernel stack memory.
> 
> Signed-off-by: Vasiliy Kulikov <segooon@gmail.com>

Acked-by: Marcel Holtmann <marcel@holtmann.org>

Regards

Marcel


