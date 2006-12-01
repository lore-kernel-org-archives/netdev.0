From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 0/5 addendum] NetXen
Date: Thu, 30 Nov 2006 20:31:23 -0500
Message-ID: <456F85EB.80308@garzik.org>
References: <20061130185602.GA32337@us.ibm.com> <456F7436.8060500@garzik.org> <20061201002743.GA17257@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amitkale@netxen.com,
	netxenproj@linsyssoft.com, rob@netxen.com, sanjeev@netxen.com,
	wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:25987 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1031709AbWLABb0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Nov 2006 20:31:26 -0500
To: Don Fry <brazilnut@us.ibm.com>
In-Reply-To: <20061201002743.GA17257@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don Fry wrote:
> On Thu, Nov 30, 2006 at 07:15:50PM -0500, Jeff Garzik wrote:
>> Don Fry wrote:
>>> The NetXen patches fix many problems in the current #upstream version of
>>> the driver.  It has warts and probably lots of bugs still, but it is
>>> better than what is queued for mainline inclusion at this time.  Please
>>> apply to 2.6.20.
>> Please resync with netdev#upstream, and update for comments on netdev...
>>
>> 	Jeff
> 
> I think I am up to date with netdev#upstream.  Maybe I am pointed at the
> wrong place.  Is the correct git tree at?
> http://www.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git/
> 
> and then to get to the upstream branch I do
> git-checkout upstream

That's the one.  The key is making sure you have the top-of-tree, it 
might not have mirrored out yet.

$ cat netdev-2.6/.git/refs/heads/upstream
5e3f6b98b639c611c45751081c59ae9a04081964
