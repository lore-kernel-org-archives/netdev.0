From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: 2.6.10 - "netdev=" kernel boot commands and the Intel e1000 nic
Date: Fri, 11 Mar 2005 10:23:54 -0800
Message-ID: <20050311182354.GA3931@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Alex Upton wrote :
> 
> We have also tried to use "nameif" as a second approach, unfortunately
> nameif seems to be limited to only having the capability to change any
> logical Ethernet device name other than eth0.

	ifrename has takeover support, however I would still
discourage you to force an interface to use the "eth0" name.

	Jean
