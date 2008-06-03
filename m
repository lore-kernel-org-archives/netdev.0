From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH]  Fix routing tables with id > 255 for legacy software
Date: Tue, 3 Jun 2008 11:47:40 +0000
Message-ID: <20080603114740.GB4714@ff.dom.local>
References: <20080603080812.GA4514@ff.dom.local> <Pine.LNX.4.64.0806031220490.3438@bizon.gios.gov.pl> <20080603113343.GA4714@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, netdev@vger.kernel.org
To: Krzysztof Oledzki <olel@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.191]:60440 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751965AbYFCLnp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 07:43:45 -0400
Received: by mu-out-0910.google.com with SMTP id w8so1481280mue.1
        for <netdev@vger.kernel.org>; Tue, 03 Jun 2008 04:43:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080603113343.GA4714@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 11:33:43AM +0000, Jarek Poplawski wrote:
> On Tue, Jun 03, 2008 at 12:37:35PM +0200, Krzysztof Oledzki wrote:
...
> > Why? If scripts are based on a recent version of iproute2 that uses  
> > RTA_TABLE then everything should work, especially there is no way to use  
> > tables with id > 255 with old iproute2.
> 
> If such an old app uses rtm_table, this 253 table could be used for

...Of course I mean when old apps are used together with new iproute2
and ids > 255...

Jarek P.
