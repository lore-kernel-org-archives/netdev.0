From: jamal <hadi@cyberus.ca>
Subject: Re: _High_ CPU usage while routing (mostly) small UDP packets
Date: 06 Dec 2004 22:18:54 -0500
Message-ID: <1102389533.1089.51.camel@jzny.localdomain>
References: <20041206224107.GA8529@soohrt.org>
	 <E1CbSf8-00047p-00@calista.eckenfels.6bone.ka-ip.net>
	 <20041207002012.GB30674@quickstop.soohrt.org>
	 <1102387595.1088.48.camel@jzny.localdomain>
	 <20041207025456.GA525@soohrt.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Bernd Eckenfels <ecki-news2004-05@lina.inka.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261747AbULGDTG@vger.kernel.org>
To: Karsten Desler <kdesler@soohrt.org>
In-Reply-To: <20041207025456.GA525@soohrt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2004-12-06 at 21:54, Karsten Desler wrote:


> The only thing I can think off is the 66/64 PCI bus and the
> disadvantageous placement of the PCI cards, but neither should cause a
> higher CPU usage. If the bus couldn't keep up, I'd get packetloss.
> 

cant tell offhand; it looks like a modern piece of hardware.
Are you sure you are using NAPI? This is an e1000, correct?

cheers,
jamal
