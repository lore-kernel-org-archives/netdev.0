From: James Morris <jmorris@redhat.com>
Subject: Re: ipsec, nat-t, iproute2?
Date: Fri, 30 Jul 2004 14:55:19 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0407301453470.20521-100000@dhcp83-76.boston.redhat.com>
References: <20040730170726.GA5144@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: bert hubert <ahu@ds9a.nl>
In-Reply-To: <20040730170726.GA5144@outpost.ds9a.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 30 Jul 2004, bert hubert wrote:

> 1) One can configure ipsec over netlink (XFRM_USER), is this the preferred
> interface? Is it documented somehwere, or is there some source which uses
> this interface? Alternatively, is PFKEY considered deprecated?

PF_KEY is not deprecated, it's an IETF standard and required for
compliance & compatibility.  XFRM_USER is simply the native Linux
interface.


- James
-- 
James Morris
<jmorris@redhat.com>
