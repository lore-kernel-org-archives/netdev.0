From: Mark Einon <mark.einon@gmail.com>
Subject: Re: [PATCH RESEND] staging: et131x: Fix errors caused by
 phydev->addr accesses before initialisation
Date: Mon, 11 Aug 2014 08:35:29 +0100
Message-ID: <20140811073529.GA4620@leicester.auvation.com>
References: <1407705415-14886-1-git-send-email-mark.einon@gmail.com>
 <CAJL_dMub6FN+HvueQ4ZJCT2TPi9-86x8VF2hG00K8CDm5bR7rw@mail.gmail.com>
 <20140811053959.GD13727@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: STAGING SUBSYSTEM <devel@driverdev.osuosl.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	stable <stable@vger.kernel.org>, gregkh@linuxfoundation.org
To: Anca Emanuel <anca.emanuel@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140811053959.GD13727@kroah.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 11, 2014 at 01:39:59PM +0800, gregkh@linuxfoundation.org wrote:
> On Mon, Aug 11, 2014 at 12:32:55AM +0300, Anca Emanuel wrote:
> > Do you have this hardware ? And did you test this ?
> 
> Mark is the maintainer of this driver, I assume he has the hardware, if
> not, I don't care, I trust him :)
> 

Hi there,

:) Yes, all tested on hardware.

> > How can you cc stable without an Tested by somebody else ?
> 
> Since when is a tested-by a requirement for a stable@ marking?  Please
> read Documentation/stable_kernel_rules.txt for the details.

As Greg says, easily if you follow those rules.

Cheers,

Mark
