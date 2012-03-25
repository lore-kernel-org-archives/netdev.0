From: Mircea Gherzan <mgherzan@gmail.com>
Subject: Re: [PATCH v8 RESEND] ARM: net: JIT compiler for packet filters
Date: Sun, 25 Mar 2012 11:51:49 +0200
Message-ID: <4F6EEAB5.7070009@gmail.com>
References: <1331933316-10197-1-git-send-email-mgherzan@gmail.com> <20120319.172005.1889334604020296555.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux@arm.linux.org.uk, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:42994 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755286Ab2CYJvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Mar 2012 05:51:54 -0400
Received: by wibhq7 with SMTP id hq7so3414314wib.1
        for <netdev@vger.kernel.org>; Sun, 25 Mar 2012 02:51:53 -0700 (PDT)
In-Reply-To: <20120319.172005.1889334604020296555.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 19.03.2012 22:20, schrieb David Miller:
> I would like to see this merged however is feasible, this has been in
> a catatonic state for two releases and waiting longer isn't going to
> improve things enough to justify any further delay.

It has been merged into the ARM tree more than a week ago, but
unfortunately it seems it will not make it into 3.4.

Mircea
