From: Doug Maxey <dwm@enoyolf.org>
Subject: Re: [PATCH 4/5] ehea: fix phyp checkpatch complaints
Date: Fri, 01 Feb 2008 22:39:57 -0600
Message-ID: <19294.1201927197@bebe.enoyolf.org>
References: <1201832451-23634-1-git-send-email-dwm@austin.ibm.com> <1201832451-23634-5-git-send-email-dwm@austin.ibm.com>  <20080201192344.GA4541@loki.buserror.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Doug Maxey <dwm@austin.ibm.com>,
	Linux PowerPC List <linuxppc-dev@ozlabs.org>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	Jeff Garzik <jgarzik@garzik.org>,
	Paul Mackerras <paulus@samba.org>, netdev@vger.kernel.org
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bebe.enoyolf.org ([24.173.215.190]:60842 "EHLO bebe.enoyolf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753415AbYBBElE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 23:41:04 -0500
In-reply-to: <20080201192344.GA4541@loki.buserror.net> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 01 Feb 2008 13:23:45 CST, Scott Wood wrote:
> On Thu, Jan 31, 2008 at 08:20:50PM -0600, Doug Maxey wrote:
> >  /* input param R5 */
> > -#define H_ALL_RES_QP_EQPO         EHEA_BMASK_IBM(9, 11)
...
> > +#define H_ALL_RES_QP_EQPO	  EHEA_BMASK_IBM(9, 11)
...
> 
> This was better the way it was (before, it was readable at any tab setting);
> checkpatch is overeager to complain on tab/space issues (it's a bit hard to
> distinguish indentation from alignment with a regex).

In emacs, with no special offsets, the lines appear to still line up.

What did happen was spaces were turned to tabs where applicable.

What editor shows a bad alignment?

++doug

