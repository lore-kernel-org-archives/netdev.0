From: "David S. Miller" <davem@redhat.com>
Subject: Re: analysis of TCP window size issues still around - several
 reports / SACK involved?
Date: Tue, 6 Jul 2004 13:31:22 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040706133122.25a05ca1.davem@redhat.com>
References: <32886.63.170.215.71.1088564087.squirrel@www.osdl.org>
	<20040629222751.392f0a82.davem@redhat.com>
	<20040630152750.2d01ca51@dell_ss3.pdx.osdl.net>
	<20040630153049.3ca25b76.davem@redhat.com>
	<20040701133738.301b9e46@dell_ss3.pdx.osdl.net>
	<20040701140406.62dfbc2a.davem@redhat.com>
	<20040702013225.GA24707@conectiva.com.br>
	<20040706093503.GA8147@outpost.ds9a.nl>
	<20040706131955.3a3c6c8b.davem@redhat.com>
	<20040706202708.GA1385@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: acme@conectiva.com.br, shemminger@osdl.org, netdev@oss.sgi.com,
        alessandro.suardi@oracle.com, phyprabab@yahoo.com
Return-path: <netdev-bounce@oss.sgi.com>
To: bert hubert <ahu@ds9a.nl>
In-Reply-To: <20040706202708.GA1385@outpost.ds9a.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 6 Jul 2004 22:27:08 +0200
bert hubert <ahu@ds9a.nl> wrote:

> On Tue, Jul 06, 2004 at 01:19:55PM -0700, David S. Miller wrote:
> 
> > What would be more interesting is to get the tcpdump trace from the
> > other side of this connection.  This is crucial, as it will show how
> > and in what way exactly the window scale options and/or window fields
> > are being edited by a firewall or other device and thus causing
> > the problems.
> 
> I have an appointment with Alessandro tomorrow evening at 11PM CEST to do
> just that.

That's great, thanks a lot.
