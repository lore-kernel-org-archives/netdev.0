From: Felix Radensky <felix@allot.com>
Subject: Re: [Fwd: kernel 2.4.21]
Date: Mon, 28 Jul 2003 18:30:49 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F2541A9.8030407@allot.com>
References: <1058634345.22000.2.camel@dhcp22.swansea.linux.org.uk>
 <20030719191723.0821227f.davem@redhat.com> <3F1E53F7.5000803@unixtech.be>
 <20030723023528.76b0f69c.davem@redhat.com> <3F1E58EE.5010109@unixtech.be>
 <20030723024648.2e4b6a62.davem@redhat.com> <3F1E7435.4060308@unixtech.be>
 <20030727163422.28e44736.davem@redhat.com> <3F24D31F.5050904@unixtech.be>
 <20030728073240.03ff1c2e.davem@redhat.com> <20030728150737.GB1399@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: "David S. Miller" <davem@redhat.com>,
   Cedric Gavage <cedric.gavage@unixtech.be>, alan@lxorguk.ukuu.org.uk,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Then maybe it makes sense to enable e100 by default and not eepro100 ?

Felix. 

Jeff Garzik wrote:

>  
>
>My Official Story(tm) is currently
>
>* use e100
>* unless you really really want to use eepro100
>
>eepro100 in the kernel tree is essentially unmaintained.  One of the
>big reasons I merged e100 is that it has an active maintainer with
>full access to docs.
>
>	Jeff
>
>
>
>
>  
>
