From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH]: altq HFSC port
Date: Mon, 26 Jan 2004 10:24:29 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040126.102429.55841404.davem@redhat.com>
References: <Pine.GSO.4.42.0401261228290.22399-200000@stinky.trash.net>
	<1075128375.1746.392.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@stinky.trash.net, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1075128375.1746.392.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: jamal <hadi@cyberus.ca>
   Date: 26 Jan 2004 09:46:16 -0500

   On Mon, 2004-01-26 at 07:02, Patrick McHardy wrote:
   > The last issue is the License: The altq version is released under a
   > BSD-style License without advertising clause (the original authors
   > kindly agreed to remove it). It is my understanding that this is
   > compatible with the GPL, and because the code includes some minor
   > amounts of GPL'ed code the correct License is GPL and not
   > Dual BSD/GPL. I would be glad if someone can confirm that this is
   > correct.
   
   This is probably the most contentious issue (given say current SCO
   stoopidty).
   Have you talked to the original author on this? I think granting you
   written consent to move to GPL may be sufficient.

Yes, let's get this worked out before we stuff it into the tree :)

Patrick, please ask the original author if it's OK to make your
instance of the Linux port pure GPL'd.
