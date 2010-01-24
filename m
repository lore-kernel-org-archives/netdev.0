From: Metuki Sabhe <sabhe.metuki@gmail.com>
Subject: Re: linux bridge problem
Date: Sun, 24 Jan 2010 17:11:23 +0200
Message-ID: <549992e51001240711r3b7ad12ct6e44cc45ec442c43@mail.gmail.com>
References: <549992e51001230641n2e40d2co31573386e258a5cb@mail.gmail.com>
	 <20100124092333.230aa8eb@opy.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f226.google.com ([209.85.219.226]:38989 "EHLO
	mail-ew0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932102Ab0AXPL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jan 2010 10:11:26 -0500
Received: by ewy26 with SMTP id 26so1250619ewy.28
        for <netdev@vger.kernel.org>; Sun, 24 Jan 2010 07:11:23 -0800 (PST)
In-Reply-To: <20100124092333.230aa8eb@opy.nosense.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Mark,

On Sun, Jan 24, 2010 at 12:53 AM, Mark Smith
<lk-netdev@lk-netdev.nosense.org> wrote:
> brctl setfd br0 0

yep, that was it! thanks! unfortunately for me i found the culprit
soon after I send the mail. should have sent earlier to save me hours
of debugging :)

thank you,
sabhe
