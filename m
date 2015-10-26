From: Otto Sabart <osabart@redhat.com>
Subject: Re: [BUG] bnx2x_config_vlan_mac called a NULL function pointer
Date: Tue, 27 Oct 2015 00:53:04 +0100
Message-ID: <20151026235304.GA26463@redhat.com>
References: <20151022194509.GA14434@redhat.com>
 <81D78EA7F834FA4C83B64260D494C859087952A8@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Adam Okuliar <aokuliar@redhat.com>,
	Jirka Hladky <jhladky@redhat.com>
To: Ariel Elior <Ariel.Elior@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44014 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751626AbbJZXxF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Oct 2015 19:53:05 -0400
Content-Disposition: inline
In-Reply-To: <81D78EA7F834FA4C83B64260D494C859087952A8@avmb3.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thank you Ariel, just let me know if you find anything.


On 23. Oct (Friday) v 08:16:01 +0000 2015, Ariel Elior wrote:
> Looking into it...
> 
> > Hello netdev,
> > I probably found a bug in kernel-4.3.0-0.rc5 (bnx2x driver). So I opened
> > new bug report in our bugzilla [0]. Michal Schmidt told me the best way
> > to solve an upstream bug is to contact you directly to netdev list.. so
> > here I am :).
> > 
> > Can somebody take a look at it?
> > 
> > [0] https://bugzilla.redhat.com/show_bug.cgi?id=1273894
> > 
