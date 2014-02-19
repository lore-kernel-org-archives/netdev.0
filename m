From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] sit: fix panic with route cache in ip tunnels
Date: Wed, 19 Feb 2014 09:10:35 -0800
Message-ID: <1392829835.18849.5.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1392826532-19282-1-git-send-email-nicolas.dichtel@6wind.com>
	 <1392828209.18849.4.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5304E0BE.3020900@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:58531 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754222AbaBSRKi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 12:10:38 -0500
Received: by mail-pd0-f169.google.com with SMTP id v10so631203pde.0
        for <netdev@vger.kernel.org>; Wed, 19 Feb 2014 09:10:38 -0800 (PST)
In-Reply-To: <5304E0BE.3020900@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-02-19 at 17:50 +0100, Nicolas Dichtel wrote:

> Yes, it's why I ask David to drop it ;-)

Yep, your mail reached my box after my answer ;)
