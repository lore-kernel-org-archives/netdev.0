From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [e1000 debug] KERNEL: assertion (!sk_forward_alloc) failed...
Date: Fri, 14 Apr 2006 15:55:10 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.63.0604141553210.2116@jbrandeb-desk.amr.corp.intel.com>
References: <Pine.WNT.4.63.0604141527420.2116@jbrandeb-desk.amr.corp.intel.com>
 <20060414.154240.30125561.davem@davemloft.net>
 <Pine.WNT.4.63.0604141543170.2116@jbrandeb-desk.amr.corp.intel.com>
 <20060414.155202.82987818.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jesse.brandeburg@intel.com, bb@kernelpanic.ru,
	herbert@gondor.apana.org.au, kernel@linuxace.com,
	nipsy@bitgnome.net, jrlundgren@gmail.com, cat@zip.com.au,
	djani22@dynamicweb.hu, yoseph.basri@gmail.com, mykleb@no.ibm.com,
	olel@ans.pl, michal@feix.cz, chris@scorpion.nl,
	netdev@vger.kernel.org, jesse.brandeburg@gmail.com,
	E1000-devel@lists.sourceforge.net, ak@suse.de, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr19.intel.com ([134.134.136.18]:38586 "EHLO
	orsfmr004.jf.intel.com") by vger.kernel.org with ESMTP
	id S1751360AbWDNW54 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Apr 2006 18:57:56 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060414.155202.82987818.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 14 Apr 2006, David S. Miller wrote:

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Date: Fri, 14 Apr 2006 15:46:31 -0700 (Pacific Daylight Time)
> 
> > sure, thats fine, but we just reproduced it in two seperate systems 
> > without the e1000 driver loaded, using the instructions as mentioned in a 
> > previous email.  We used a 5704 with TSO enabled.
> 
> That I didn't notice, thanks for the datapoint.

you're welcome, its "hot off the presses" (we just reproduced it 5 minutes 
ago) 

I'm trying to isolate more of a reproduction case, I'll be sure to post if 
I can find anything with more detail.
