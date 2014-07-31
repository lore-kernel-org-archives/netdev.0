From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH 1/1] Drivers: net-next: hyperv
Date: Thu, 31 Jul 2014 00:31:56 +0000
Message-ID: <5d85f8205f3840449e0b678bab49e777@BY2PR0301MB0711.namprd03.prod.outlook.com>
References: <1406769616-29871-1-git-send-email-kys@microsoft.com>
 <20140730.172523.1080858143706717134.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>
To: David Miller <davem@davemloft.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20140730.172523.1080858143706717134.davem@davemloft.net>
Content-Language: en-US
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



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, July 30, 2014 5:25 PM
> To: KY Srinivasan
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
> devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
> jasowang@redhat.com
> Subject: Re: [PATCH 1/1] Drivers: net-next: hyperv
> 
> From: "K. Y. Srinivasan" <kys@microsoft.com>
> Date: Wed, 30 Jul 2014 18:20:16 -0700
> 
> > For forwarding scenarios, it will be useful to allocate larger
> > sendbuf. Make the necessary adjustments to permit this.
> >
> > Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
> 
> Please submit this with a proper Subject line, something like "[PATCH 1/1]
> hyperv: ${DESCRIPTION}" would be fine.
> 
> As is, nobody scanning the commit headers in the tree history can see what
> might be unique about this change to the hyperv driver vs. all others,
> because you haven't written a proper description.
Oops; sorry about that. I will resend this.

K. Y
