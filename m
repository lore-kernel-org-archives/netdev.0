From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [patch 2.6.9 0/11] Add MODULE_VERSION to several network drivers
Date: Thu, 21 Oct 2004 08:22:05 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021082205.A29340@tuxdriver.com>
References: <20041020141146.C8775@tuxdriver.com> <1098350269.2810.17.camel@laptop.fenrus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org, jgarzik@pobox.com,
        davem@davemloft.net, john.ronciak@intel.com,
        ganesh.venkatesan@intel.com, akpm@osdl.org, romieu@fr.zoreil.com,
        ctindel@users.sourceforge.net, fubar@us.ibm.com,
        greearb@candelatech.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arjan van de Ven <arjan@fenrus.demon.nl>
Content-Disposition: inline
In-Reply-To: <1098350269.2810.17.camel@laptop.fenrus.com>; from arjan@fenrus.demon.nl on Thu, Oct 21, 2004 at 11:17:49AM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Oct 21, 2004 at 11:17:49AM +0200, Arjan van de Ven wrote:
> On Wed, 2004-10-20 at 20:11, John W. Linville wrote:
> > Patches to add MODULE_VERSION lines to several network drivers...
> > 
> > Here is the list:
> 
> have you checked if the version of these drivers is actually useful? (eg
> updated when the driver changes) If it's not I'd say adding a
> MODULE_VERSION to it makes no sense whatsoever.

Why do I feel like I'm being baited...? :-)

I would have to suspect that if a version string exists, that it has at
least some meaning to the primary developers/maintainters.  It certainly
is beyond my control to force the maintainers to give meaning to their
version strings.

Is this a political statement against the MODULE_VERSION macro and/or
its purpose?  I'm not overly interested in debating that one...

John
-- 
John W. Linville
linville@tuxdriver.com
