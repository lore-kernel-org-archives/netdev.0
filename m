From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 1/2] Sysfs net class - infrastructure
Date: Thu, 15 May 2003 18:42:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030516014255.GA12288@kroah.com>
References: <20030515162717.477fb84b.shemminger@osdl.org> <20030516002023.GA11926@kroah.com> <20030515.175810.42792746.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, mochel@osdl.org, netdev@oss.sgi.com,
   jkenisto@us.ibm.com, lkessler@us.ibm.com, dsteklof@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030515.175810.42792746.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, May 15, 2003 at 05:58:10PM -0700, David S. Miller wrote:
>    > +	/* statistics object */
>    > +	struct kobject		stats_kobj;
>    
>    What is this needed for?  I don't remember seeing this in your previous
>    patches :)
> 
> He provides a sub-directory containing statistic value files.
> I have no problem with this.

Doh, missed that, sorry.  That looks nice.

greg k-h
