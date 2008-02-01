From: Doug Maxey <dwm@enoyolf.org>
Subject: Re: [PATCH 0/5] ehea checkpatch fixups
Date: Thu, 31 Jan 2008 22:35:18 -0600
Message-ID: <472.1201840518@bebe.enoyolf.org>
References: <1201832451-23634-1-git-send-email-dwm@austin.ibm.com>  <20080201030542.GX14201@localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Doug Maxey <dwm@austin.ibm.com>, Jeff Garzik <jgarzik@garzik.org>,
	Linux PowerPC List <linuxppc-dev@ozlabs.org>,
	netdev@vger.kernel.org, Paul Mackerras <paulus@samba.org>,
	Jan-Bernd Themann <themann@de.ibm.com>
To: Nathan Lynch <ntl@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bebe.enoyolf.org ([24.173.215.190]:50794 "EHLO bebe.enoyolf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934646AbYBAFEA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 00:04:00 -0500
In-reply-to: <20080201030542.GX14201@localdomain> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 31 Jan 2008 21:05:42 CST, Nathan Lynch wrote:
> Doug Maxey wrote:
> > 
> > A small set of fixups for checkpatch.
> > 
> > Based on upstream pull from a few hours ago.
> 
> Er, ehea doesn't even build right now[1], maybe that could get fixed
> first?  :-)
> 
> [1] http://lkml.org/lkml/2008/1/28/337

For sure these won't break it any worse.  ;)  Think of these more as a 
janitorial thing vs. structural.

Doesn't gregkh's patch work?  At least for the interim?

Jan-Bernd,
What tools are looking in sysfs? distro scripts?  I don't see any link 
between ethtool and the driver (other than the driver internal bits).
Am I missing something obvious?

++doug




