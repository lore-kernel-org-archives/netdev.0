From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: Established sockets remain open after iface down or address lost
Date: Tue, 1 Oct 2013 20:33:04 +0400
Message-ID: <CAMrnHh6Lr9q27yiSmJ-EbJMTeUVyf9650vK+6QmbfTVfz_omxg@mail.gmail.com>
References: <20130926060433.GA9170@cverges-dev-lnx.sentient-energy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
To: Chris Verges <cverges@sentient-energy.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:50147 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750964Ab3JAQdF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 12:33:05 -0400
Received: by mail-ie0-f173.google.com with SMTP id ar20so14438705iec.32
        for <netdev@vger.kernel.org>; Tue, 01 Oct 2013 09:33:04 -0700 (PDT)
In-Reply-To: <20130926060433.GA9170@cverges-dev-lnx.sentient-energy.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

> P.S.  I apologize in advance if I missed this answer in the netdev archives.

FYI googling f.e. "netdev tcp remove local address" instantly  finds
all that you want to know. Namrly, subj: Re: "TCP shutdown behaviour
when deleting local IP addresses"
