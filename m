From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH] Comment sysfs directory tagging
Date: Tue, 4 May 2010 10:25:14 -0500
Message-ID: <20100504152514.GB18700@us.ibm.com>
References: <20100503212315.GA4141@us.ibm.com>
 <4BE0292F.4000007@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <gregkh@suse.de>,
	"Eric W. Biederman" <ebiederm@xmission.com>, bcrl@lhnet.ca,
	benjamin.thery@bull.net, cornelia.huck@de.ibm.com,
	eric.dumazet@gmail.com, kay.sievers@vrfy.org,
	netdev@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:53503 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933044Ab0EDPZR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 May 2010 11:25:17 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e8.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o44B6RkC022636
	for <netdev@vger.kernel.org>; Tue, 4 May 2010 07:06:27 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o44FPGdC114362
	for <netdev@vger.kernel.org>; Tue, 4 May 2010 11:25:16 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o44FPF2x000359
	for <netdev@vger.kernel.org>; Tue, 4 May 2010 11:25:16 -0400
Content-Disposition: inline
In-Reply-To: <4BE0292F.4000007@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Tejun Heo (tj@kernel.org):
> Hello,
> 
> On 05/03/2010 11:23 PM, Serge E. Hallyn wrote:
> > (against gregkh-2.6)
> > 
> > Add some in-line comments to explain the new infrastructure, which
> > was introduced to support sysfs directory tagging with namespaces.
> > I think an overall description someplace might be good too, but it
> > didn't really seem to fit into Documentation/filesystems/sysfs.txt,
> > which appears more geared toward users, rather than maintainers, of
> > sysfs.
> > 
> > (Tejun, please let me know if I can make anything clearer or failed
> > altogether to comment something that should be commented.)
> 
> This sure is an improvement but yeah I agree that having an overall
> documentation would be great.  If there isn't a matching one, just
> create one - sysfs-ns.txt, sysfs-tagged.txt or whatever.

I'll try to whip something up tonight.

-serge
