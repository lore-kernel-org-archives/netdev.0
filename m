From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] net: add the AF_KCM entries to family
 name tables
Date: Mon, 21 Mar 2016 11:27:42 -0400 (EDT)
Message-ID: <20160321.112742.1737417108964275737.davem@davemloft.net>
References: <1458553869-26756-1-git-send-email-decui@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, gregkh@linuxfoundation.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org, apw@canonical.com,
 devel@linuxdriverproject.org, haiyangz@microsoft.com
To: decui@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1458553869-26756-1-git-send-email-decui@microsoft.com>
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


Two things wrong with this submission:

1) You need to provide an initial "[PATCH net-next 0/3] ..." header posting
   explaining at a high level what this patch series is about and how it is
   implemented and why.

2) The net-next tree is closed at this time because we are in the merge window,
   therefore no new feature patches should be submitted to the netdev mailing
   list at this time.  Please wait until some (reasonable) amount of time after
   the merge window closes to resubmit this.

Thanks.
