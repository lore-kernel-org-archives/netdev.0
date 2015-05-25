From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH] staging: r8712u: Fix kernel warning for improper call of
 del_timer_sync()
Date: Mon, 25 May 2015 13:12:07 +0300
Message-ID: <20150525101207.GC22558@mwanda>
References: <1432415812-1285-1-git-send-email-Larry.Finger@lwfinger.net>
 <CAJ=9CzbPmo+f4zjY4CqQ7TsUENpwy+zHcpxeLTbAH0DAZSkqsQ@mail.gmail.com>
 <556268BC.5050807@lwfinger.net> <20150525091737.GQ4150@mwanda>
 <CAK-LDb+1WscLTFw=NDY=_aUOGw72a4wRsqCU-1N+KJ11k15S5w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, Sudip Mukherjee <sudip@vectorindia.org>,
 Greg KH <gregkh@linuxfoundation.org>, linux-wireless@vger.kernel.org,
 Stable <stable@vger.kernel.org>, netdev@vger.kernel.org,
 Haggai Eran <haggai.eran@gmail.com>, Arek Rusniak <arek.rusi@gmail.com>,
 Larry Finger <Larry.Finger@lwfinger.net>
To: Vaishali Thakkar <vthakkar1994@gmail.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <CAK-LDb+1WscLTFw=NDY=_aUOGw72a4wRsqCU-1N+KJ11k15S5w@mail.gmail.com>
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

On Mon, May 25, 2015 at 03:07:08PM +0530, Vaishali Thakkar wrote:
> I am sorry for those patches. It was me who introduced those bugs. Yes, it
> was sent during Outreachy process. But it was my mistake as a newbie. May
> be I should have taken care of interrupt mode thing.
> 
> I would like to fix it if someone is not doing it. Sorry again. I will take
> care of these things in my future patches.

No, it's not your fault for making mistakes.  We *expect* newbies to
make mistakes.

It's Greg's fault for merging these when they weren't sent to the list
or to the other maintainers.  But Greg knows I'm annoyed already since
we have been dealing with the fallout for months and I always make sure
to complain whenever I have a chance.  /me shakes a fist!  Grrr....  :P

regards,
dan carpenter
