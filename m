From: Hasso Tepper <hasso@estpak.ee>
Subject: Re: primary and secondary ip addresses
Date: Fri, 17 Dec 2004 20:03:22 +0200
Message-ID: <200412172003.22319.hasso@estpak.ee>
References: <41912F7A.6000408@redhat.com> <41C30212.6000906@cs.columbia.edu> <Pine.LNX.4.61.0412171736210.17463@filer.marasystems.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andrea G Forte <andreaf@cs.columbia.edu>,
	Harald Welte <laforge@gnumonks.org>,
	Neil Horman <nhorman@redhat.com>, linux-net@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Henrik Nordstrom <hno@marasystems.com>
In-Reply-To: <Pine.LNX.4.61.0412171736210.17463@filer.marasystems.com>
Content-Disposition: inline
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Henrik Nordstrom wrote:
> On Fri, 17 Dec 2004, Andrea G Forte wrote:
> > This does not help, since if I want to use my secondary IP address
> > instead of my primary, I cannot delete the primary otherwise all of my
> > secondary IPs are lost as well (and since I can only have only one
> > primary IP address).
>
> Why change the primary address? What is wrong with simply changing the
> route to use the other source IP?

There is no support for it in most of user space software. None of the 
routing protocols suites support it etc.

-- 
Hasso Tepper
Elion Enterprises Ltd.
WAN administrator
