From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: [PATCH v2 1/6] net-PPP: Replacement of a printk() call by pr_warn()
 in mppe_rekey()
Date: Fri, 05 Dec 2014 09:49:35 +0100
Message-ID: <5481719F.4050801@users.sourceforge.net>
References: <5307CAA2.8060406@users.sourceforge.net>	 <530C5E18.1020800@users.sourceforge.net>	 <alpine.DEB.2.10.1402251014170.2080@hadrien>	 <530CD2C4.4050903@users.sourceforge.net>	 <alpine.DEB.2.10.1402251840450.7035@hadrien>	 <530CF8FF.8080600@users.sourceforge.net>	 <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6>	 <530DD06F.4090703@users.sourceforge.net>	 <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>	 <5317A59D.4@users.sourceforge.net> <547B4886.4080406@users.sourceforge.net>	 <547B496E.604@users.sourceforge.net> <547C5CBC.6060607@cogentembedded.com>	 <547C82A6.2030808@users.sourceforge.net>	 <547CA157.1080401@cogentembedded.com>	 <5480DA32.8000201@users.sourceforge.net>	 <5480DBDE.7040604@users.sourceforge.net>	 <1417731809.2721.17.camel@perches.com>	 <548
 0DFB5.4090708@users.sourceforge.net>	 <1417733101.2721.20.camel@perches.com>	 <54815C5F.8090702@users.sourceforge.net> <1417766255.2721.43.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Paul Mackerras <paulus@samba.org>, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417766255.2721.43.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> It's a process, and it's not immediate.  Wait to see
> if these get applied as-is.

Thanks for your constructive feedback.


> If the embedded function name use, which is trivial, bothers you,
> send another patch later on that changes it.

Not really at the moment ...

I guess that I would prefer a general development of another semantic
patch approach according to your request with the topic "Finding embedded
function names?" a moment ago.
https://systeme.lip6.fr/pipermail/cocci/2014-December/001517.html
http://article.gmane.org/gmane.comp.version-control.coccinelle/4399

Regards,
Markus
