From: jamal <hadi@cyberus.ca>
Subject: Re: _High_ CPU usage while routing (mostly) small UDP packets
Date: 06 Dec 2004 22:30:41 -0500
Message-ID: <1102390241.1093.59.camel@jzny.localdomain>
References: <20041206224107.GA8529@soohrt.org>
	 <E1CbSf8-00047p-00@calista.eckenfels.6bone.ka-ip.net>
	 <20041207002012.GB30674@quickstop.soohrt.org>
	 <1102387595.1088.48.camel@jzny.localdomain>
	 <20041207025456.GA525@soohrt.org>
	 <1102389533.1089.51.camel@jzny.localdomain>
	 <20041207032438.GA7767@soohrt.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Bernd Eckenfels <ecki-news2004-05@lina.inka.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261712AbULGDa5@vger.kernel.org>
To: Karsten Desler <kdesler@soohrt.org>
In-Reply-To: <20041207032438.GA7767@soohrt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2004-12-06 at 22:24, Karsten Desler wrote:
> roller (rev 03)
> 
> driver: e1000
> version: 5.5.4-k2-NAPI
> firmware-version: N/A
> bus-info: 0000:01:03.0
> 
> driver: e1000
> version: 5.5.4-k2-NAPI
> firmware-version: N/A
> bus-info: 0000:01:01.0

Beats me. Make sure it boots NAPI. Also if you can turn off ITR; intel
loves to turn on that silly feature.


cheers,
jamal
