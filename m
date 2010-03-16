From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: Re: [PATCH net-2.6 2/3] jme: Adding lock to protect vlgrp structure.
Date: Tue, 16 Mar 2010 15:49:45 +0800
Message-ID: <20100316071753.M36702@cooldavid.org>
References: <1268630108-10374-1-git-send-email-cooldavid@cooldavid.org> <1268630108-10374-2-git-send-email-cooldavid@cooldavid.org> <20100315.155453.143098808.davem@davemloft.net>
Reply-To: cooldavid@cooldavid.org
Mime-Version: 1.0
Content-Type: text/plain;
	charset=big5
Cc: netdev@vger.kernel.org, ethanhsiao@jmicron.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([114.33.45.68]:48715 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757156Ab0CPHuE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Mar 2010 03:50:04 -0400
In-Reply-To: <20100315.155453.143098808.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 15 Mar 2010 15:54:53 -0700 (PDT), David Miller wrote
> Please respin this whole patch set when you fix this
> vlgrp locking the way I told you to.
> 
> Also, please don't submit a seperate series for 2.6.33 it only creates
> confusion.  Just add a "CC: stable@kernel.org" right after your
> signoff line and it'll get sorted out automatically once the patch
> reaches Linus's tree.
Now I see the "stable_kernel_rules.txt", sorry for the careless.

BTW, is it OK if the patch can only apply on net-2.6 tree cleanly,
but have some Hunks applying to stable kernel? If it is intended
for both net-2.6 and stable kernel.

Guo-Fu Tseng

