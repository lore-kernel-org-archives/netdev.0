From: Roman Kagan <rkagan@mail.ru>
Subject: Re: [Linux-ATM-General] [RFC][PATCH] Very basic sysfs support for ATM devices (updated)
Date: Tue, 8 Feb 2005 19:45:47 +0300
Message-ID: <20050208164547.GA2928@katya>
References: <20050206191918.GA2369@katya> <200502081502.j18F2ITI010672@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@oss.sgi.com, linux-atm-general@lists.sourceforge.net
Content-Disposition: inline
In-Reply-To: <200502081502.j18F2ITI010672@ginger.cmf.nrl.navy.mil>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Feb 08, 2005 at 10:02:19AM -0500, chas williams - CONTRACTOR wrote:
> >it is, maybe we shouldn't create an atm-specific user-visible interface
> >in sysfs and hotplug which is going to be obsoleted by the net generic
> >one in the near future?
> 
> with sysfs support the only thing left to 'fix' would be splitting of
> allocation/registration.

I beg your pardon, but are you saying that you've changed your mind re.
moving to net_device?  Is your plan now to cast in stone that ATM
devices live under class/atm in sysfs, and go ahead with splitting of
allocation/registration of the current atm_dev?

Roman.
