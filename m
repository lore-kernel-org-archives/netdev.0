From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH 1/4] staging: rtl8712: Remove casts between void * and
 type *
Date: Tue, 24 Nov 2015 16:07:30 +0300
Message-ID: <20151124130730.GZ18797@mwanda>
References: <1448367582-8041-1-git-send-email-mukadr@gmail.com>
 <1448367582-8041-2-git-send-email-mukadr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, florian.c.schilhabel@googlemail.com,
 netdev@vger.kernel.org, gregkh@linuxfoundation.org, Larry.Finger@lwfinger.net
To: Mauro Dreissig <mukadr@gmail.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1448367582-8041-2-git-send-email-mukadr@gmail.com>
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

On Tue, Nov 24, 2015 at 10:19:39AM -0200, Mauro Dreissig wrote:
> Cleaning rtl871x_ioctl_rtl.c.
> 

It's better if you think about the header and the body as two different
things.  Just repeat the title but with more information.

regards,
dan carpenter
