From: Chuck Ebbert <cebbert@redhat.com>
Subject: Re: all syscalls initially taking 4usec on a P4? Re: nonblocking
 	UDPv4 recvfrom() taking 4usec @ 3GHz?
Date: Wed, 21 Feb 2007 11:25:31 -0500
Message-ID: <45DC727B.7000802@redhat.com>
References: <20070219231447.GA4400@outpost.ds9a.nl>	 <p73d545drx6.fsf@bingen.suse.de> <20070220162714.GA3245@outpost.ds9a.nl>	 <20070220164124.GA24930@2ka.mipt.ru>	 <20070220184242.GA30077@filer.fsl.cs.sunysb.edu>	 <20070220184859.GA1949@2ka.mipt.ru> <20070220193319.GA8800@outpost.ds9a.nl>	 <45DB6FD8.4050106@hp.com>  <20070220221719.GA16263@outpost.ds9a.nl> <1172010148.3531.158.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: bert hubert <bert.hubert@netherlabs.nl>,
	Rick Jones <rick.jones2@hp.com>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Josef Sipek <jsipek@fsl.cs.sunysb.edu>,
	Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422663AbXBUQ0k@vger.kernel.org>
In-Reply-To: <1172010148.3531.158.camel@laptopd505.fenrus.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arjan van de Ven wrote:
> also.. running "vmstat 3" and looking at the "cs" column is interesting;
> it shouldn't be above 50 or so in idle (well not above 10 but our
> userland stinks too much for that)

I average 6 or so with my normal configuration.


Chuck "kill the daemons" Ebbert
