From: David Daney <ddaney@avtrex.com>
Subject: Re: RFC3927 ARP patch status?
Date: Fri, 02 Jun 2006 09:36:54 -0700
Message-ID: <44806926.1050509@avtrex.com>
References: <20060602143837.GF549@progsoc.uts.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from adsl-67-116-42-147.dsl.sntc01.pacbell.net ([67.116.42.147]:26146
	"EHLO avtrex.com") by vger.kernel.org with ESMTP id S932100AbWFBQgz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jun 2006 12:36:55 -0400
To: Anand Kumria <wildfire@progsoc.uts.edu.au>
In-Reply-To: <20060602143837.GF549@progsoc.uts.edu.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Anand Kumria wrote:
> Hi David,
> 
> Do you know the status of your RFC3927 ARP patch? Is it likely to make
> it into a mainline kernel?
> 

That would be up to the kernel network maintainers.

There were some discussions about whether it made sense for the kernel 
to support the behavior required by the RFC.  Other comments debated the 
wisdom of using a tightly targeted patch specific to the RFC, or whether 
a more general but intrusive solution would be better.

The patch is there.  I signed-off-by on it.

If you need RFC3927 compliance, you are free to apply the patch.  If the 
  network maintainers are so inclined, they can do the necessary things 
to get it into the mainline.

David Daney
