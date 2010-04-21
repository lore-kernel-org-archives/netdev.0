From: Narendra Choyal <narendrachoyal@gmail.com>
Subject: Re: PROBLEM: Linux kernel 2.6.31 IPv4 TCP fails to open huge amount
	of outgoing connections (unable to bind ... )
Date: Thu, 22 Apr 2010 00:33:01 +0530
Message-ID: <u2u186ebf761004211203t4ec5c24fqd81138ed4010e02f@mail.gmail.com>
References: <g2z46c8cb3e1004201517i5641a75cze2ec5bd33e81fb0f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Gaspar Chilingarov <gasparch@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:37101 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752264Ab0DUTDB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 15:03:01 -0400
Received: by pwj9 with SMTP id 9so5397115pwj.19
        for <netdev@vger.kernel.org>; Wed, 21 Apr 2010 12:03:01 -0700 (PDT)
In-Reply-To: <g2z46c8cb3e1004201517i5641a75cze2ec5bd33e81fb0f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

use the following command
this will help you out to more connetions

#ip link set eth0 mtu 69

and increase the size of buffer[]

I think this will helps you ( I am student yet now )
