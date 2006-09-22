From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: Re: [PATCH 2.6.17][Trivial] net/dccp: update references to standards
Date: Fri, 22 Sep 2006 15:22:54 +1200
Message-ID: <5640c7e00609212022p4b9f85a5t93ca9ada4206ad8f@mail.gmail.com>
References: <200609141644.32243@strip-the-willow>
	 <200609141649.33877@strip-the-willow>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, dccp@vger.kernel.org,
	"Arnaldo Carvalho de Melo" <acme@mandriva.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.131]:31866 "EHLO
	nf-out-f131.google.com") by vger.kernel.org with ESMTP
	id S932248AbWIVDW4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Sep 2006 23:22:56 -0400
Received: by nf-out-f131.google.com with SMTP id k65so9826nfa
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2006 20:22:55 -0700 (PDT)
To: "Gerrit Renker" <gerrit@erg.abdn.ac.uk>
In-Reply-To: <200609141649.33877@strip-the-willow>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnaldo - this looks good.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

On 9/15/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Sorry kmail garbled this, clean text below.
>
> - Gerrit
> --
>
> diff --git a/net/dccp/Kconfig b/net/dccp/Kconfig
> index 859e335..2c345c0 100644
> --- a/net/dccp/Kconfig
> +++ b/net/dccp/Kconfig
> @@ -4,9 +4,9 @@ menu "DCCP Configuration (EXPERIMENTAL)"
>  config IP_DCCP
>         tristate "The DCCP Protocol (EXPERIMENTAL)"
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
