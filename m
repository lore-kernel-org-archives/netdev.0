From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] LSM networking: skb hooks for 2.5.42 (2/7)
Date: Tue, 15 Oct 2002 13:28:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021015202828.GG15864@kroah.com>
References: <20021015194545.GC15864@kroah.com> <20021015.124502.130514745.davem@redhat.com> <20021015201209.GE15864@kroah.com> <20021015.131037.96602290.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: becker@scyld.com, jmorris@intercode.com.au, kuznet@ms2.inr.ac.ru,
   netdev@oss.sgi.com, linux-security-module@wirex.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20021015.131037.96602290.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Oct 15, 2002 at 01:10:37PM -0700, David S. Miller wrote:
> 
> I will not even look at the networking LSM bits until
> CONFIG_SECURITY=n is available.

Good enough reason for me, I'll start working on this.  Help from the
other LSM developers is appreciated :)

thanks,

greg k-h
