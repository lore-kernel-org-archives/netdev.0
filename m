From: "Bill Rugolsky Jr." <brugolsky@telemetry-investments.com>
Subject: Re: MSEC_TO_JIFFIES is messed up...
Date: Wed, 12 May 2004 18:44:54 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040512224454.GJ21953@ti64.telemetry-investments.com>
References: <20040512020700.6f6aa61f.akpm@osdl.org> <20040512181903.GG13421@kroah.com> <40A26FFA.4030701@pobox.com> <20040512205407.GD25515@ti64.telemetry-investments.com>
Reply-To: "Bill Rugolsky Jr." <brugolsky@telemetry-investments.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <greg@kroah.com>, Andrew Morton <akpm@osdl.org>, mingo@elte.hu,
        linux-kernel@vger.kernel.org, Netdev <netdev@oss.sgi.com>,
        Sridhar Samudrala <sri@us.ibm.com>, davem@redhat.com,
        George Anzinger <george@mvista.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20040512205407.GD25515@ti64.telemetry-investments.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, May 12, 2004 at 04:54:07PM -0400, Bill Rugolsky Jr. wrote:
> The attached patch combines Sridhar's consolidation patch with my
> more accurate routines in the spirit of the rest of time.h.  It is against
> 2.6.6-rc3-bk3.  Feedback welcome.  I'm happy to rediff against latest kernel,
> I just haven't had time the last few days.
 
Sorry to reply to myself, but please ignore the patch that I sent;
upon reflection, the 64-bit logic is (still) wrong.

	Bill Rugolsky
