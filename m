From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Generic Netlink HOW-TO based on Jamal's original doc
Date: Tue, 14 Nov 2006 07:53:41 +0100
Message-ID: <20061114065341.GA1006@ff.dom.local>
References: <45541757.90800@hp.com> <20061110132450.GA4307@ff.dom.local> <20061110173642.GL8693@postel.suug.ch> <20061113072347.GB1892@ff.dom.local> <4558CE59.60907@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:36001 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S1755443AbWKNGrr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Nov 2006 01:47:47 -0500
To: Paul Moore <paul.moore@hp.com>
Content-Disposition: inline
In-Reply-To: <4558CE59.60907@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 13, 2006 at 02:58:17PM -0500, Paul Moore wrote:
> Jarek Poplawski wrote:
> > @@ -586,7 +586,7 @@
> >        goto failure;
> >    }
> >    /* add a DOC_EXMPL_A_MSG attribute */
> > -  rc = nla_put_string(skb, DOC_EXMPL_A_MSG, "Generic Netlink Rocks");
> > +  rc = nla_put_string(skb, DOC_EXMPL_A_MSG, "Justin Timberlake rocks");
> >    if (rc != 0)
> >        goto failure;
> >    /* finalize the message */
> 
> So here I am applying this patch by hand because the diffs are a bit off and I
> come across this ... I think I might have to nix this change on the basis of
> rudimentary quality standards :)
> 
> Besides, *I* brought sexy back.

It's too late!

"My Love" (clip) nixed all possible standards
so you'll have to update it soon anyway...

Jarek P.
