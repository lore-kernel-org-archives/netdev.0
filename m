From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 4/4] atl1: Ancillary C files for Attansic L1 driver
Date: Sat, 27 Jan 2007 17:38:45 -0500
Message-ID: <45BBD475.4050101@garzik.org>
References: <20070121210737.GE2702@osprey.hogchain.net> <20070121183151.4be61ebf.randy.dunlap@oracle.com> <45B43093.6060500@bellsouth.net> <20070122200004.GA12553@dreamland.darkstar.lan> <20070123112522.65aac61b@freekitty> <20070123211917.GA22109@dreamland.darkstar.lan> <45BBBDD0.7030809@bellsouth.net> <45BBC10C.5010103@garzik.org> <45BBCCA2.4090902@bellsouth.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: csnook@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, atl1-devel@lists.sourceforge.net
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55395 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751954AbXA0Wit (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Jan 2007 17:38:49 -0500
In-Reply-To: <45BBCCA2.4090902@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Cliburn wrote:
> Jeff Garzik wrote:
>> As a driver maintainer, you need to patch sets, and submit them in a 
>> timely fashion to me.  Note I said patch set, not patch, in following 
>> with Rule #3 from Documentation/SubmittingPatches.  Also make sure to 
>> review http://linux.yyz.us/patch-format.html
> 
> Understood.  Both references reviewed.  Thanks.
> 
> Sorry, but one last question...  These two patches generated overnight 
> by Andrew:
> 
> Message-Id: <200701270710.l0R7AhLj004217@shell0.pdx.osdl.net>
> Subject: + git-netdev-all-atl1-pm-fix.patch added to -mm tree
> 
> and
> 
> Message-Id: <200701270708.l0R78Q0o004191@shell0.pdx.osdl.net>
> Subject: + git-netdev-all-atl1-build-fix.patch added to -mm tree
> 
> Do I include these in my patch set that I submit to you, or do you apply 
> them to netdev directly?

There is no hard and fast rule.  If the patch is obvious and submitted 
in correct form (Andrew's notifications are not in such a form), then I 
might go ahead and apply it.  But I usually reply to the patch with 
"applied" if so.

In general, you can answer this question yourself.  Look at 
netdev-2.6.git#atl1 and see what's in there.

	Jeff



