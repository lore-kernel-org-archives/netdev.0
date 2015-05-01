From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next 2/2] rhashtable: Quick initial growth of tables
Date: Fri, 1 May 2015 15:38:25 +0200
Message-ID: <20150501133825.GB5784@pox.localdomain>
References: <1430434005-6143-1-git-send-email-tgraf@suug.ch>
 <1430434005-6143-3-git-send-email-tgraf@suug.ch>
 <55435DC3.4060304@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, kaber@trash.net
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:34690 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753703AbbEANi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 09:38:28 -0400
Received: by wgso17 with SMTP id o17so91159387wgs.1
        for <netdev@vger.kernel.org>; Fri, 01 May 2015 06:38:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <55435DC3.4060304@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/01/15 at 02:04pm, Sergei Shtylyov wrote:
> >+	return log > 1 ? log : 1;
> 
>    max(log, 1)?

Sure
