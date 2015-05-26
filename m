From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] staging: r8712u: Fix kernel warning for improper call
 of del_timer_sync()
Date: Tue, 26 May 2015 07:48:59 -0700
Message-ID: <1432651739.2846.93.camel@perches.com>
References: <1432415812-1285-1-git-send-email-Larry.Finger@lwfinger.net>
	 <CAJ=9CzbPmo+f4zjY4CqQ7TsUENpwy+zHcpxeLTbAH0DAZSkqsQ@mail.gmail.com>
	 <556268BC.5050807@lwfinger.net> <20150525091737.GQ4150@mwanda>
	 <1432575448.2846.63.camel@perches.com> <20150526044611.GA3465@sudip-PC>
	 <1432616108.2846.83.camel@perches.com> <20150526050212.GC3465@sudip-PC>
	 <1432616879.2846.86.camel@perches.com> <20150526141401.GC21573@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Sudip Mukherjee <sudipm.mukherjee@gmail.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	devel@driverdev.osuosl.org,
	Sudip Mukherjee <sudip@vectorindia.org>,
	linux-wireless@vger.kernel.org, Stable <stable@vger.kernel.org>,
	netdev@vger.kernel.org, Haggai Eran <haggai.eran@gmail.com>,
	Arek Rusniak <arek.rusi@gmail.com>,
	Larry Finger <Larry.Finger@lwfinger.net>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20150526141401.GC21573@kroah.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-05-26 at 07:14 -0700, Greg KH wrote:
> On Mon, May 25, 2015 at 10:07:59PM -0700, Joe Perches wrote:
> > As far as I understand, the Eudyptula Challenge list has
> > internal mechanisms to nominally review patches before some
> > patch is submitted to lkml.
> 
> No it does not.

That's not quite what was described to me by someone behind the
email address:
"Little Penguin <little@eudyptula-challenge.org>" back in August.

What I understood from that email was there is a qualifying
formatting component to the challenge and then patches were to be
sent to maintainers and lists.

> > The main point is that patches shouldn't be applied without
> > being submitted to a more widely read list.
> 
> I take the blame for any problems with Outreachy patches.

Are you going to change any procedure associated to these
Outreachy patches?
