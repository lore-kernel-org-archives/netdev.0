From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] Fix crash on big-endian systems during scan
Date: Mon, 17 Apr 2006 12:44:55 -0400
Message-ID: <20060417164450.GM5042@tuxdriver.com>
References: <20060414215911.17273.40460.stgit@dv.roinet.com> <20060417010602.GL9551@jm.kir.nu> <20060417132105.GF5042@tuxdriver.com> <1145284443.2212.5.camel@localhost.localdomain> <20060417144541.GK5042@tuxdriver.com> <1145286089.2649.0.camel@localhost.localdomain> <20060417151659.GL5042@tuxdriver.com> <1145288203.2649.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, hostap@shmoo.com,
	Pavel Roskin <proski@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([24.172.12.4]:49924 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1751037AbWDQQpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2006 12:45:18 -0400
To: Dan Williams <dcbw@redhat.com>
Content-Disposition: inline
In-Reply-To: <1145288203.2649.3.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 17, 2006 at 11:36:43AM -0400, Dan Williams wrote:
> On Mon, 2006-04-17 at 11:17 -0400, John W. Linville wrote:
> > On Mon, Apr 17, 2006 at 11:01:29AM -0400, Dan Williams wrote:
> > > On Mon, 2006-04-17 at 10:45 -0400, John W. Linville wrote:
> > > > On Mon, Apr 17, 2006 at 10:34:03AM -0400, Dan Williams wrote:
> > > > 
> > > > > Pavel posted to netdev originally on Friday April 14th with the patch
> > > > > included in the email, with the title "[PATCH] Fix crash on big-endian
> > > > > systems during scan"...
> > > > > 
> > > > > http://www.spinics.net/lists/netdev/msg03023.html
> > > > > 
> > > > > Sure you don't have it somewhere?  If not, I'm sure somebody can
> > > > > resend...
> > > > 
> > > > I must have fat-fingered a delete...sorry!
> > > > 
> > > > A repost would be most welcome...
> > > 
> > > I think Pavel just resent the patch with a "(repost)" at the end of the
> > > subject line.
> > 
> > Hmmm...Randy Dunlap said offline that he had reposted, but I haven't
> > seen one from him either...is it a big patch?
> 
> Two liner...
> 
> From: Pavel Roskin <proski@gnu.org>
> 
> The original code was doing arithmetics on a little-endian value.
> Reported by Stelios Koroneos <stelios@stelioscellar.com>
> 
> Signed-off-by: Pavel Roskin <proski@gnu.org>
> ---

Got this one...thanks!

-- 
John W. Linville
linville@tuxdriver.com
