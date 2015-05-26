From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH] staging: r8712u: Fix kernel warning for improper call of
 del_timer_sync()
Date: Tue, 26 May 2015 23:25:43 +0300
Message-ID: <20150526202543.GD11734@mwanda>
References: <20150525091737.GQ4150@mwanda>
 <1432575448.2846.63.camel@perches.com>
 <20150526044611.GA3465@sudip-PC>
 <1432616108.2846.83.camel@perches.com>
 <20150526050212.GC3465@sudip-PC>
 <1432616879.2846.86.camel@perches.com>
 <20150526141401.GC21573@kroah.com>
 <1432651739.2846.93.camel@perches.com>
 <20150526163555.GA9685@kroah.com>
 <1432659977.2846.100.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, Sudip Mukherjee <sudip@vectorindia.org>,
 Greg KH <gregkh@linuxfoundation.org>, Haggai Eran <haggai.eran@gmail.com>,
 linux-wireless@vger.kernel.org, Stable <stable@vger.kernel.org>,
 netdev@vger.kernel.org, Arek Rusniak <arek.rusi@gmail.com>,
 Larry Finger <Larry.Finger@lwfinger.net>
To: Joe Perches <joe@perches.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1432659977.2846.100.camel@perches.com>
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

On Tue, May 26, 2015 at 10:06:17AM -0700, Joe Perches wrote:
> If you're collecting them, I suggest you stick them in
> a separate branch, post them to your driverdev list and
> cc the appropriate maintainers, wait a week, then apply
> them to your main branch.

That would work.  A massive thread is easy to delete.  Or even just
apply them first, and we tell people to send follow on patches or revert
as needed.  My whole setup revolves around email so finding and
reviewing patches using git log is awkward.

regards,
dan carpenter
