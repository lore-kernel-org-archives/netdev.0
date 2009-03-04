From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: [BUG?] iproute2/skbedit bug?
Date: Wed, 4 Mar 2009 23:48:34 +0200
Message-ID: <200903042348.35053.denys@visp.net.lb>
References: <200903042146.37807.denys@visp.net.lb> <200903042342.09287.denys@visp.net.lb> <80769D7B14936844A23C0C43D9FBCF0F2C0F5D6C@orsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shemminger@osdl.org" <shemminger@osdl.org>
To: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:47017 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754539AbZCDVsn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 16:48:43 -0500
In-Reply-To: <80769D7B14936844A23C0C43D9FBCF0F2C0F5D6C@orsmsx501.amr.corp.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok, sorry, i will try latest git

On Wednesday 04 March 2009 23:46:47 Duyck, Alexander H wrote:
> Denys Fedoryschenko wrote:
> > On Wednesday 04 March 2009 23:36:07 Duyck, Alexander H wrote:
> >> Are you using the latest version off of the git tree or the version
> >> tagged v2.6.28?  There was a fix applied 13 days ago to the git tree
> >> version which resolves an issue with uninitialized memory being used
> >> in configuring the skbedit action.  This was causing "File Exists"
> >> errors similar to what you are seeing now.
> >
> > 2.6.29-rc6-git7
> > I will try rc7 now
>
> Are you talking about the kernel or the iproute package?  The git tree I
> was referring to was the iproute tools package.
>
> http://www.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git
>
> Thanks,
>
> Alex
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


