From: "David S. Miller" <davem@redhat.com>
Subject: Re: [Fwd: kernel 2.4.21]
Date: Wed, 23 Jul 2003 02:35:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030723023528.76b0f69c.davem@redhat.com>
References: <1058634345.22000.2.camel@dhcp22.swansea.linux.org.uk>
	<20030719191723.0821227f.davem@redhat.com>
	<3F1E53F7.5000803@unixtech.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Cedric Gavage <cedric.gavage@unixtech.be>
In-Reply-To: <3F1E53F7.5000803@unixtech.be>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 23 Jul 2003 11:23:03 +0200
Cedric Gavage <cedric.gavage@unixtech.be> wrote:

> Still this with 2.4.21 kernel: (intel internet card, driver eepro100)
> 
> Jul 23 07:25:58 fazer kernel: recvmsg bug: copied 7CB284C0 seq 7CB288AE
> Jul 23 07:25:58 fazer kernel: KERNEL: assertion (flags&MSG_PEEK) failed at tcp.c(1563)

What interesting programs are you running on this system?

Are you running and old version of vsftpd?
