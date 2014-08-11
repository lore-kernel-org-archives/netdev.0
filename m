From: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
Subject: Re: [PATCH RESEND] staging: et131x: Fix errors caused by
 phydev->addr accesses before initialisation
Date: Mon, 11 Aug 2014 13:39:59 +0800
Message-ID: <20140811053959.GD13727@kroah.com>
References: <1407705415-14886-1-git-send-email-mark.einon@gmail.com>
 <CAJL_dMub6FN+HvueQ4ZJCT2TPi9-86x8VF2hG00K8CDm5bR7rw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: STAGING SUBSYSTEM <devel@driverdev.osuosl.org>,
 Mark Einon <mark.einon@gmail.com>, LKML <linux-kernel@vger.kernel.org>,
 stable <stable@vger.kernel.org>, netdev@vger.kernel.org
To: Anca Emanuel <anca.emanuel@gmail.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <CAJL_dMub6FN+HvueQ4ZJCT2TPi9-86x8VF2hG00K8CDm5bR7rw@mail.gmail.com>
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

On Mon, Aug 11, 2014 at 12:32:55AM +0300, Anca Emanuel wrote:
> Do you have this hardware ? And did you test this ?

Mark is the maintainer of this driver, I assume he has the hardware, if
not, I don't care, I trust him :)

> How can you cc stable without an Tested by somebody else ?

Since when is a tested-by a requirement for a stable@ marking?  Please
read Documentation/stable_kernel_rules.txt for the details.

thanks,

greg k-h
