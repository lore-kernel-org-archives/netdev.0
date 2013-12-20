From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 01/11] staging: r8188eu: Remove pointless thread_exit macro
Date: Fri, 20 Dec 2013 14:43:23 -0600
Message-ID: <52B4ABEB.4000704@lwfinger.net>
References: <1387514323-4486-1-git-send-email-Larry.Finger@lwfinger.net>
 <1387514323-4486-2-git-send-email-Larry.Finger@lwfinger.net>
 <20131220165859.GA12829@kroah.com> <52B47CDB.506@lwfinger.net>
 <20131220191816.GB27254@kroah.com> <52B4A8EF.1010109@lwfinger.net>
 <20131220203456.GA14617@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20131220203456.GA14617@kroah.com>
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

On 12/20/2013 02:34 PM, Greg KH wrote:
> Nah, I just switched to 4.8 and rebuilt all of the different kernel
> trees on this box with it, so I'll stay there for now.

The problem wasn't the fault of gcc 4.8. I only use the staging tree to base 
patches to send to you, and my .config in that directory was missing one of the 
options for r8188eu. I have found what I think are all the unused variables in 
the driver. The patch will be sent shortly.

Thanks,

Larry
