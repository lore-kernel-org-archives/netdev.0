From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] qdisc: allow setting default queuing discipline
Date: Thu, 29 Aug 2013 05:02:01 -0700
Message-ID: <1377777721.8277.27.camel@edumazet-glaptop>
References: <20130827161908.26062336@nehalam.linuxnetplumber.net>
	 <1377662448.8828.155.camel@edumazet-glaptop>
	 <1377665870.8828.163.camel@edumazet-glaptop>
	 <20130828091836.5c8285f4@nehalam.linuxnetplumber.net>
	 <1377710453.8277.11.camel@edumazet-glaptop>
	 <20130828102835.2cfa5d41@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:36569 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752963Ab3H2MCE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 08:02:04 -0400
Received: by mail-pd0-f180.google.com with SMTP id y10so364646pdj.11
        for <netdev@vger.kernel.org>; Thu, 29 Aug 2013 05:02:03 -0700 (PDT)
In-Reply-To: <20130828102835.2cfa5d41@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-08-28 at 10:28 -0700, Stephen Hemminger wrote:

> 
> Hate to say it but maybe module parameter to htb would be an alternative
> if you have to deal with that.

Fair enough ;)

Anyway, it turned out all I needed was the MQ change ;)
