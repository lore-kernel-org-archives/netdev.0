From: Mark Einon <mark.einon@gmail.com>
Subject: Re: [RFC PATCH linux-next] et131x: Promote staging et131x driver to
 drivers/net
Date: Tue, 23 Sep 2014 10:51:18 +0100
Message-ID: <20140923095118.GC5130@leicester.auvation.com>
References: <1411421283-25073-1-git-send-email-mark.einon@gmail.com>
 <20140922235653.GA17359@angus-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org
To: Angus Gibson <angus@agibson.me>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <20140922235653.GA17359@angus-mbp>
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

On Tue, Sep 23, 2014 at 09:56:53AM +1000, Angus Gibson wrote:
> > +config NET_VENDOR_AGERE
> > +	bool "Agere devices"
> > +	default y
> > +	depends on PCI
> > +	---help---
> > +	  If you have a network (Ethernet) card belonging to this class, say =
> > Y
> > +	  and read the Ethernet-HOWTO, available from
> > +	  <http://www.tldp.org/docs.html#howto>.
> > +
> > +	  Note that the answer to this question doesn't directly affect the
> > +	  kernel: saying N will just cause the configurator to skip all
> > +	  the questions about Atheros devices. If you say Y, you will be aske=
> should this be "Agere devices" instead?

Yes it should - well spotted, thanks - I'll change this in v2.

Mark
