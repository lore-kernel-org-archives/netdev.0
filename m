From: Olaf van der Spek <olafvdspek@gmail.com>
Subject: Re: TCP_DEFER_ACCEPT is missing counter update
Date: Wed, 14 Oct 2009 23:12:52 +0200
Message-ID: <b2cc26e40910141412l45c3074flbb80a26cd57bd10d@mail.gmail.com>
References: <20091013050705.GA2194@1wt.eu>
	 <20091013.001106.226276168.davem@davemloft.net>
	 <20091013071955.GA3587@1wt.eu>
	 <Pine.LNX.4.58.0910132335390.3095@u.domain.uli>
	 <20091014045226.GA15655@1wt.eu>
	 <Pine.LNX.4.58.0910140912420.2714@u.domain.uli>
	 <20091014201706.GA24298@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f188.google.com ([209.85.210.188]:34690 "EHLO
	mail-yx0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760269AbZJNVTi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 17:19:38 -0400
Received: by yxe26 with SMTP id 26so218462yxe.4
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2009 14:19:02 -0700 (PDT)
In-Reply-To: <20091014201706.GA24298@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 14, 2009 at 10:17 PM, Willy Tarreau <w@1wt.eu> wrote:
> Yes and I already use that, this gives substantial performance
> boosts on small HTTP requests ; unfortunately I have no control
> over the end-user's browser !

Most accept feature requests, don't they?

Olaf
