From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Drivers: net: hyperv: Cleanup the recive path
Date: Sat, 01 Feb 2014 17:01:38 -0800 (PST)
Message-ID: <20140201.170138.2222640901661791450.davem@davemloft.net>
References: <1391185478-5655-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, apw@canonical.com, devel@linuxdriverproject.org
To: kys@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1391185478-5655-1-git-send-email-kys@microsoft.com>
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

From: "K. Y. Srinivasan" <kys@microsoft.com>
Date: Fri, 31 Jan 2014 08:24:38 -0800

> Some minor cleanup of the receive path. Get rid of unnecessary
> indirection as well as unnecessary re-establishment of state.

It is not appropriate to submit cleanups at this time.

Please wait until the net-next tree opens back up, and submit
your changes against it at that time.
