From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 1/3] ifb: remove the useless debug stats
Date: Sat, 04 Dec 2010 09:12:57 -0500
Message-ID: <1291471977.2159.3.camel@mojatatu>
References: <1291442121-3302-1-git-send-email-xiaosuo@gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:34189 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754987Ab0LDONC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Dec 2010 09:13:02 -0500
Received: by gyb11 with SMTP id 11so5276925gyb.19
        for <netdev@vger.kernel.org>; Sat, 04 Dec 2010 06:13:02 -0800 (PST)
In-Reply-To: <1291442121-3302-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-12-04 at 13:55 +0800, Changli Gao wrote:
> These debug stats are not exported, and become useless.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Given the complexity of ifb, these stats have proved useful over
the years - I would typically ask someone to printk them etc.
If you want me to get me excited (in a good way) you could export these
via link XSTATS ;-> If you dont have time, then it is likely
we are stable enough we can kill them in which case, here you go:

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

cheers,
jamal

