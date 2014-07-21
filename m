From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Hyperv: Trigger DHCP renew after host hibernation
Date: Mon, 21 Jul 2014 14:32:25 -0700 (PDT)
Message-ID: <20140721.143225.2040366896972949930.davem@davemloft.net>
References: <DC7803B42427924284F2D5252E076A3B4476A479@SINEX14MBXC416.southpacific.corp.microsoft.com>
 <53CCD6F2.6020909@nod.at> <20140721091851.GA28171@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: richard@nod.at, jasowang@redhat.com, driverdev-devel@linuxdriverproject.org,
 haiyangz@microsoft.com, linux-kernel@vger.kernel.org, huishao@microsoft.com,
 yuezha@microsoft.com, gregkh@linuxfoundation.org, netdev@vger.kernel.org
To: olaf@aepfle.de
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20140721091851.GA28171@aepfle.de>
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

From: Olaf Hering <olaf@aepfle.de>
Date: Mon, 21 Jul 2014 11:18:51 +0200

> On Mon, Jul 21, Richard Weinberger wrote:
> 
>> My concern is that 10 seconds is maybe not a the right choice.
>> (As we cannot know all implementations)
> 
> Until someone reports an issue with it, 10 is fine. Just like 20 or 666.

Wrong, this is policy and belongs in userspace.
