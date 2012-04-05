From: Dave Jones <davej@redhat.com>
Subject: Re: kernel BUG at include/net/netns/generic.h:41
Date: Thu, 5 Apr 2012 12:12:41 -0400
Message-ID: <20120405161241.GA23658@redhat.com>
References: <20120328002346.GB3077@redhat.com>
 <20120402172600.GA3728@redhat.com>
 <1333390230.13718.34.camel@lade.trondhjem.org>
 <4F7DC37F.7090404@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41274 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753919Ab2DEQNH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Apr 2012 12:13:07 -0400
Content-Disposition: inline
In-Reply-To: <4F7DC37F.7090404@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 05, 2012 at 08:08:31PM +0400, Stanislav Kinsbursky wrote:

 > So, there are few questions to you, Dave:
 > 1) can this happen (PipeFS mount attempt before SUNPRC module insertion has 
 > returned any value) in your case?

I don't know enough of what systemd is doing to answer this.

 > 2) how often do you experience this problem? Not every boot, I suppose?
 > 3) And is it easy for you to reproduce?

It happens most the time, but not every time.

	Dave
