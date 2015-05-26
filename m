From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH] staging: r8712u: Fix kernel warning for improper call of
 del_timer_sync()
Date: Tue, 26 May 2015 23:09:42 +0300
Message-ID: <20150526200941.GC11734@mwanda>
References: <556268BC.5050807@lwfinger.net> <20150525091737.GQ4150@mwanda>
 <1432575448.2846.63.camel@perches.com>
 <20150526044611.GA3465@sudip-PC>
 <1432616108.2846.83.camel@perches.com>
 <20150526050212.GC3465@sudip-PC>
 <1432616879.2846.86.camel@perches.com>
 <20150526141401.GC21573@kroah.com>
 <1432651739.2846.93.camel@perches.com>
 <20150526163555.GA9685@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, Sudip Mukherjee <sudip@vectorindia.org>,
 netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
 Stable <stable@vger.kernel.org>, Haggai Eran <haggai.eran@gmail.com>,
 Joe Perches <joe@perches.com>, Arek Rusniak <arek.rusi@gmail.com>,
 Larry Finger <Larry.Finger@lwfinger.net>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <20150526163555.GA9685@kroah.com>
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

On Tue, May 26, 2015 at 09:35:55AM -0700, Greg KH wrote:
> Also, the outreachy patch process would overwhelm everyone else on the
> list, it's really high volume during the application phase, I'd prefer
> it to stick with the mentors that wish to help out with the process.  If
> you and/or Dan, or anyone else wishes to help out with this, I would
> really appreciate it.  But I don't think that forcing them to post to
> the driverdevel list is a good idea.

If it makes your life easier to merge them directly from outreachy
that's great and I'm ok with that, but don't skip the normal review
process as a favour to us.

regards,
dan carpenter
