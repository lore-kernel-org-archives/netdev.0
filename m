From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: TOE brain dump
Date: Sun, 03 Aug 2003 02:41:33 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F2CAE9D.5090401@pobox.com>
References: <ODEIIOAOPGGCDIKEOPILKEKKDAAA.alan@storlinksemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>, Nivedita Singhvi <niv@us.ibm.com>,
   Werner Almesberger <werner@almesberger.net>, netdev@oss.sgi.com,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Alan Shih <alan@storlinksemi.com>
In-Reply-To: <ODEIIOAOPGGCDIKEOPILKEKKDAAA.alan@storlinksemi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Alan Shih wrote:
> A DMA xfer that fills the NIC pipe with IDE source. That's not very hard...
> need a lot of bufferring/FIFO though.  May require large modification to the
> file serving applications?


Nope, that's using the existing sendfile(2) facility.

	Jeff
