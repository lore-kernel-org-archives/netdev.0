From: Cedric Gavage <cedric.gavage@unixtech.be>
Subject: Re: [Fwd: kernel 2.4.21]
Date: Wed, 23 Jul 2003 11:23:03 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F1E53F7.5000803@unixtech.be>
References: <1058634345.22000.2.camel@dhcp22.swansea.linux.org.uk> <20030719191723.0821227f.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030719191723.0821227f.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> 
>>>Jul 17 06:31:00 fazer kernel: KERNEL: assertion (newsk->state != 
>>>TCP_SYN_RECV) failed at tcp.c(2229)
> 
> 
> This one was fixed in 2.4.21
> 

Still this with 2.4.21 kernel: (intel internet card, driver eepro100)

Jul 23 07:25:58 fazer kernel: recvmsg bug: copied 7CB284C0 seq 7CB288AE
Jul 23 07:25:58 fazer kernel: KERNEL: assertion (flags&MSG_PEEK) failed 
at tcp.c(1563)
Jul 23 07:25:58 fazer kernel: recvmsg bug: copied 7CB284C0 seq 7CB288AE
Jul 23 07:25:58 fazer kernel: KERNEL: assertion (flags&MSG_PEEK) failed 
at tcp.c(1563)
Jul 23 07:25:58 fazer kernel: recvmsg bug: copied 7CB284C0 seq 7CB288AE
Jul 23 07:25:58 fazer kernel: KERNEL: assertion (flags&MSG_PEEK) failed 
at tcp.c(1563)
Jul 23 07:25:58 fazer kernel: recvmsg bug: copied 7CB284C0 seq 7CB288AE
Jul 23 07:25:58 fazer kernel: KERNEL: assertion (flags&MSG_PEEK) failed 
at tcp.c(1563)
Jul 23 07:25:58 fazer kernel: recvmsg bug: copied 7CB284C0 seq 7CB288AE
Jul 23 07:25:58 fazer kernel: KERNEL: assertion (flags&MSG_PEEK) failed 
at tcp.c(1563)
Jul 23 07:25:58 fazer kernel: recvmsg bug: copied 7CB284C0 seq 7CB288AE
Jul 23 07:25:58 fazer kernel: KERNEL: assertion (flags&MSG_PEEK) failed 
at tcp.c(1563)
Jul 23 07:25:58 fazer kernel: recvmsg bug: copied 7CB284C0 seq 7CB288AE
Jul 23 07:25:58 fazer kernel: KERNEL: assertion (flags&MSG_PEEK) failed 
at tcp.c(1563)
Jul 23 07:25:58 fazer kernel: recvmsg bug: copied 7CB284C0 seq 7CB288AE
Jul 23 07:25:58 fazer kernel: KERNEL: assertion (flags&MSG_PEEK) failed 
at tcp.c(1563)


Any idea?

-- 
  Cedric Gavage <cedric.gavage@unixtech.be>
  http://unixtech.be - http://gavage.com - OpenPGP: 0xED325C64
