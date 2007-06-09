From: jamal <hadi@cyberus.ca>
Subject: Re: [XFRM] Introduce standalone SAD lookup
Date: Sat, 09 Jun 2007 10:23:04 -0400
Message-ID: <1181398984.4077.26.camel@localhost>
References: <1181398686.4077.19.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	James Morris <jmorris@namei.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.179]:24003 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752751AbXFIOXI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jun 2007 10:23:08 -0400
Received: by py-out-1112.google.com with SMTP id a29so1753623pyi
        for <netdev@vger.kernel.org>; Sat, 09 Jun 2007 07:23:07 -0700 (PDT)
In-Reply-To: <1181398686.4077.19.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry, meant to cc Herbert and James since they commented two
generations ago.
Gents, if you manage to have the cycles please look at this specific
one. Herbert, for tunnel mode i think i will agree with you and
introduce a dst struct; but i will defer that to some later patch.

cheers,
jamal

On Sat, 2007-09-06 at 10:18 -0400, jamal wrote:
> 3 of 4.
> 
> cheers,
> jamal

