From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] rtnetlink.7: add missing RTA_* attributes
Date: Mon, 21 Mar 2016 12:04:49 -0700
Message-ID: <20160321120449.42cd6f50@xeon-e3>
References: <1458043587-5115-1-git-send-email-mq@ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mtk.manpages@gmail.com,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Lubomir Rintel <lkundrak@v3.sk>, netdev@vger.kernel.org,
	linux-man@vger.kernel.org
To: Jan Moskyto Matejka <mq@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:35850 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757814AbcCUT2U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2016 15:28:20 -0400
Received: by mail-pf0-f172.google.com with SMTP id u190so277190347pfb.3
        for <netdev@vger.kernel.org>; Mon, 21 Mar 2016 12:28:19 -0700 (PDT)
In-Reply-To: <1458043587-5115-1-git-send-email-mq@ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Mar 2016 13:06:27 +0100
Jan Moskyto Matejka <mq@ucw.cz> wrote:

> Used Bird's source code, kernel source code, iproute2 source code and
> iproute2 manpages to find meanings of these new attributes.
> 
> Signed-off-by: Jan Moskyto Matejka <mq@ucw.cz>

This is patch against linux man pages (not iproute2)
