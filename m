From: "David S. Miller" <davem@davemloft.net>
Subject: Re: tg3 kernel oops when setting flow control while interface is
 down (2.6.10)
Date: Mon, 14 Mar 2005 21:42:31 -0800
Message-ID: <20050314214231.78d369b0.davem@davemloft.net>
References: <B1508D50A0692F42B217C22C02D84972020F3DF9@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: d.willmann@tu-bs.de, netdev@oss.sgi.com, jluebbe@lasnet.de,
        davem@redhat.com
To: "Michael Chan" <mchan@broadcom.com>
In-Reply-To: <B1508D50A0692F42B217C22C02D84972020F3DF9@NT-IRVA-0741.brcm.ad.broadcom.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 11 Mar 2005 09:19:05 -0800
"Michael Chan" <mchan@broadcom.com> wrote:

> O.K., so if there is no objection, I will create some patches for all
> relevant tg3 ethtool "set" functions to handle the !netif_running() case as
> described above. I think this is better as new settings can be accepted at
> any time.

No objection at all.  Let me know when you have a patch for
review.
