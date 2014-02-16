From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH 02/13] staging: r8188eu: Remove pointless "alignment"
 entry in recv_frame
Date: Sun, 16 Feb 2014 12:09:56 +0300
Message-ID: <20140216090956.GG26722@mwanda>
References: <1392418457-3203-1-git-send-email-Larry.Finger@lwfinger.net>
 <1392418457-3203-3-git-send-email-Larry.Finger@lwfinger.net>
 <87ob27bvz7.fsf@will.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, gregkh@linuxfoundation.org,
 Jes.Sorensen@redhat.com, netdev@vger.kernel.org,
 Larry Finger <Larry.Finger@lwfinger.net>
To: "Zhao, Gang" <gamerh2o@gmail.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <87ob27bvz7.fsf@will.lan>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 16, 2014 at 11:02:52AM +0800, Zhao, Gang wrote:
> On Sat, 2014-02-15 at 06:54:06 +0800, Larry Finger wrote:
> > This alignment entry in union recv_frame does nothing. It certainly
> > dues not ensure alignment.
>    ^
>    typo here.
> 
>    I accidently sent this as a private mail before, better to resend to
>    the list.
> 

This was already applied.  You can still understand the meaning so it's
fine.  No need to redo.  Typos in the code are more important.

It's hard to run spell checkers on patches since so much of the words
are code and not English.

regards,
dan carpenter
