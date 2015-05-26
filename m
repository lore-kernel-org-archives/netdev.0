From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: Re: [PATCH] staging: r8712u: Fix kernel warning for improper call of
 del_timer_sync()
Date: Tue, 26 May 2015 11:00:22 +0530
Message-ID: <20150526053022.GA4585@sudip-PC>
References: <1432415812-1285-1-git-send-email-Larry.Finger@lwfinger.net>
 <CAJ=9CzbPmo+f4zjY4CqQ7TsUENpwy+zHcpxeLTbAH0DAZSkqsQ@mail.gmail.com>
 <556268BC.5050807@lwfinger.net> <20150525091737.GQ4150@mwanda>
 <1432575448.2846.63.camel@perches.com>
 <20150526044611.GA3465@sudip-PC>
 <1432616108.2846.83.camel@perches.com>
 <20150526050212.GC3465@sudip-PC>
 <1432616879.2846.86.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, Sudip Mukherjee <sudip@vectorindia.org>,
 gregkh@linuxfoundation.org, Haggai Eran <haggai.eran@gmail.com>,
 linux-wireless@vger.kernel.org, Stable <stable@vger.kernel.org>,
 Arek Rusniak <arek.rusi@gmail.com>, netdev@vger.kernel.org,
 Dan Carpenter <dan.carpenter@oracle.com>,
 Larry Finger <Larry.Finger@lwfinger.net>
To: Joe Perches <joe@perches.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1432616879.2846.86.camel@perches.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Mon, May 25, 2015 at 10:07:59PM -0700, Joe Perches wrote:
> On Tue, 2015-05-26 at 10:32 +0530, Sudip Mukherjee wrote:
> > On Mon, May 25, 2015 at 09:55:08PM -0700, Joe Perches wrote:
> > > On Tue, 2015-05-26 at 10:16 +0530, Sudip Mukherjee wrote:
> > > > On Mon, May 25, 2015 at 10:37:28AM -0700, Joe Perches wrote:

> > But for eudyptula, patches have to properly submitted to lkml and
> > maintainers. And today I am here just because of eudyptula. My patches
> > and contributions here, everything started with it. :)
> 
> As far as I understand, the Eudyptula Challenge list has
> internal mechanisms to nominally review patches before some
> patch is submitted to lkml.
well, yes, sort of. Submitting patch is task 10, and all the previous
tasks will train people on creating patch, sending etc.
> 
> The main point is that patches shouldn't be applied without
> being submitted to a more widely read list.
yes, and Eudyptula requires the participant to send patch to maintainer,
lkml and relevant mailing list where outreachy specifies not to send to
lkml. Next outreachy will start from September.

regards
sudip
