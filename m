From: Paul Moore <paul.moore@hp.com>
Subject: Re: Generic Netlink HOW-TO based on Jamal's original doc
Date: Mon, 13 Nov 2006 14:58:17 -0500
Message-ID: <4558CE59.60907@hp.com>
References: <45541757.90800@hp.com> <20061110132450.GA4307@ff.dom.local> <20061110173642.GL8693@postel.suug.ch> <20061113072347.GB1892@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:45989 "EHLO atlrel9.hp.com")
	by vger.kernel.org with ESMTP id S933050AbWKMT6W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Nov 2006 14:58:22 -0500
To: Jarek Poplawski <jarkao2@o2.pl>
In-Reply-To: <20061113072347.GB1892@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> @@ -586,7 +586,7 @@
>        goto failure;
>    }
>    /* add a DOC_EXMPL_A_MSG attribute */
> -  rc = nla_put_string(skb, DOC_EXMPL_A_MSG, "Generic Netlink Rocks");
> +  rc = nla_put_string(skb, DOC_EXMPL_A_MSG, "Justin Timberlake rocks");
>    if (rc != 0)
>        goto failure;
>    /* finalize the message */

So here I am applying this patch by hand because the diffs are a bit off and I
come across this ... I think I might have to nix this change on the basis of
rudimentary quality standards :)

Besides, *I* brought sexy back.

-- 
paul moore
linux security @ hp
