From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH 00/10] sysfs tagged directories
Date: Tue, 29 Apr 2008 11:41:51 -0700
Message-ID: <20080429184151.GA19794@suse.de>
References: <20080429171015.473938697@theryb.frec.bull.fr> <20080429173621.GA16625@suse.de> <20080429180445.GA18110@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Thery <benjamin.thery@bull.net>,
	linux-kernel@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Tejun Heo <htejun@gmail.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>, netdev@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:40843 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756224AbYD2Sr4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 14:47:56 -0400
Content-Disposition: inline
In-Reply-To: <20080429180445.GA18110@sergelap.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 29, 2008 at 01:04:45PM -0500, Serge E. Hallyn wrote:
> Quoting Greg KH (gregkh@suse.de):
> > On Tue, Apr 29, 2008 at 07:10:15PM +0200, Benjamin Thery wrote:
> > > Here is the announcement Eric wrote back in December to introduce his 
> > > patchset:
> > 
> > <snip>
> > 
> > Are the objections that Al Viro made to this patchset when it was last
> > sent out addressed in this new series?
> > 
> > thanks,
> > 
> > greg k-h
> 
> Which objections were those?  The last submission which I see by Eric
> was http://lkml.org/lkml/2007/12/1/15 this past December.  I see no
> response from Al and get the feeling you were ok with them.
> 
> So my hunch would be that Eric had addressed those before that last
> submission, but if not I'm sorry, and please do set me straight.

See the thread from Al starting with:
	Date: Mon, 7 Jan 2008 10:24:17 +0000
	From: Al Viro <viro@ZenIV.linux.org.uk>
	To: "Eric W. Biederman" <ebiederm@xmission.com>
	Cc: linux-kernel@vger.kernel.org, htejun@gmail.com,
	        linux-fsdevel@vger.kernel.org, gregkh@suse.de
	Subject: [RFC] netns / sysfs interaction
	Message-ID: <20080107072301.GW27894@ZenIV.linux.org.uk>

He had a lot of questions and objections to this way forward, and I
share those objections.

thanks,

greg k-h
