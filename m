From: jamal <hadi@cyberus.ca>
Subject: Re: linux_mib docs?
Date: Fri, 28 Feb 2003 08:27:43 -0500 (EST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030228082235.F53276@shell.cyberus.ca>
References: <20030227111212.40388562.rddunlap@osdl.org> <20030227201651.GA24698@wotan.suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Randy.Dunlap" <rddunlap@osdl.org>, "" <linux-net@vger.kernel.org>,
	"" <netdev@oss.sgi.com>
Return-path: <linux-net-owner@vger.kernel.org>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20030227201651.GA24698@wotan.suse.de>
List-Id: netdev.vger.kernel.org



On Thu, 27 Feb 2003, Andi Kleen wrote:

> On Thu, Feb 27, 2003 at 11:12:12AM -0800, Randy.Dunlap wrote:
> > Hi,
> >
> > Is there a MIB definition for struct linux_mib in
> > include/net/snmp.h ?
>
> Not that I'm aware of, but netstat -s has (very) brief descriptions.
>


If there was a MIB where that would fit it would be called the
"linux private network" MIB. This is pretty common practise
when you have additional things that dont fit the standards.
The rest of the objects in that file are typically exported to RFC1213.

cheers,
jamal
