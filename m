From: terry white <twhite@aniota.com>
Subject: Re: [PATCH v2 1/6] net-PPP: Replacement of a printk() call by
 pr_warn() in mppe_rekey()
Date: Fri, 5 Dec 2014 14:35:54 -0800 (PST)
Message-ID: <Pine.LNX.4.64.1412051403160.20522@yossarian>
References: <5307CAA2.8060406@users.sourceforge.net>  <530B5FB6.6010207@users.sourceforge.net>
  <alpine.DEB.2.10.1402241710370.2074@hadrien>  <530C5E18.1020800@users.sourceforge.net>
  <alpine.DEB.2.10.1402251014170.2080@hadrien>  <530CD2C4.4050903@users.sourceforge.net>
  <alpine.DEB.2.10.1402251840450.7035@hadrien>  <530CF8FF.8080600@users.sourceforge.net>
  <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6>
 <530DD06F.4090703@users.sourceforge.net>  <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
  <5317A59D.4@users.sourceforge.net> <547C5CBC.6060607@cogentembedded.com>
 <547C82A6.2030808@users.sourceforge.net>  <547CA157.1080401@cogentembedded.com>
  <5480DA32.8000201@users.sourceforge.net>  <5480DBDE.7040604@users.sourceforge.net>
  <1417731809.2721.17.camel@perches.com>  <5480DFB5.4090708@users.sourceforge.net>
  <1417733101.2721.20.camel@perches.com>  <54815C5F.8090702@users.sourceforge.net>
 <1417766255.2721.43.camel@perches.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-ppp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417766255.2721.43.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

... ciao:

: on "12-4-2014" "Joe Perches" writ:
: > Does it make sense to express such implementation details in the Linux 
: > coding style documentation more explicitly (besides the fact that this 
: > update suggestion was also triggered by a warning from the script 
: > "checkpatch.pl".
: 
: Probably not.
: 
: Overly formalized coding style rules are perhaps
: more of a barrier to entry than most want.
 
   funny you should mention that.  as nothing more than a casual observer, 
i'm noticing a "TIRED" sensation reading this thread.  i have "0" 
confidence a "SERIOUS" participant's enthusiasm would remain untested.
 
   however, the "checkpatch.pl" warning suggests an assumed 'custom'. i 
can't tell if this a 'serious' issue, or "pickin' fly shit out of pepper".
 
   but from my reading of it, the "CODE" , and the "logic" driving it, is 
not the problem.

    season's best ...

-- 
... it's not what you see ,
    but in stead , notice ...
