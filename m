From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: netfilter is not a filesystem
Date: Fri, 11 Feb 2011 07:58:05 +0100
Message-ID: <20110211065805.GB2914@riccoc20.at.omicron.at>
References: <bug-28862-10286@https.bugzilla.kernel.org/>
 <20110210141119.56d789fc.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110210141119.56d789fc.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 10, 2011 at 02:11:19PM -0800, Andrew Morton wrote:
> On Thu, 10 Feb 2011 21:55:26 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
> 
> > https://bugzilla.kernel.org/show_bug.cgi?id=28862
> > 
> >            Summary: /proc/net/ip_conntrack: no space left on device
> >                     systematically
> 
> This is why I'm forever nagging people to not just grab some errno
> because its name happens to sound similar to the error you just detected.

Today my brain has thrown an -EMIXEDMESSAGES:

   https://lkml.org/lkml/2011/2/10/172

Sorry, couldn't resist,

Richard
