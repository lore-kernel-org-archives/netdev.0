From: James Morris <jmorris@redhat.com>
Subject: Re: Fw: [Bugme-new] [Bug 3151] New: IPSEC triggers "bad: scheduling
 while atomic!" errors.
Date: Wed, 4 Aug 2004 09:00:09 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0408040858561.8700-100000@dhcp83-76.boston.redhat.com>
References: <20040803224319.50363100.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20040803224319.50363100.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 3 Aug 2004, Andrew Morton wrote:

> 
> Looks like a lock/unlock imbalance somewhere in the 2.6.7 ipsec code.

This could also be ppp related, oops related to this code seem to be 
reported regularly.


- James
-- 
James Morris
<jmorris@redhat.com>
