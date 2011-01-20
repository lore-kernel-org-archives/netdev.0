From: gerrit@erg.abdn.ac.uk
Subject: Re: [PATCH clean-up] dccp: clean up unused DCCP_STATE_MASK
     definition
Date: Thu, 20 Jan 2011 11:38:41 -0000 (GMT)
Message-ID: <58207.148.187.160.35.1295523521.squirrel@148.187.160.35>
References: <4D37FC96.9000407@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: acme@ghostprotocols.net, dccp@vger.kernel.org,
	"Network-Maillist" <netdev@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>,
	"Gerrit Renker" <gerrit@erg.abdn.ac.uk>
To: "Shan Wei" <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:43207 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755296Ab1ATLuc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jan 2011 06:50:32 -0500
In-Reply-To: <4D37FC96.9000407@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Remove unused DCCP_STATE_MASK macro.
>
>
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

> --- a/include/linux/dccp.h
> +++ b/include/linux/dccp.h
> @@ -279,8 +279,6 @@ enum dccp_state {
>  	DCCP_MAX_STATES
>  };
>
> -#define DCCP_STATE_MASK 0x1f

