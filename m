From: "David S. Miller" <davem@redhat.com>
Subject: Re: [BK PATCH] Make eth.c independent of dev->hard_header_len
Date: Sun, 29 Sep 2002 17:56:39 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020929.175639.12656717.davem@redhat.com>
References: <3D974A3D.40207@pobox.com>
	<Pine.LNX.4.44.0209291406410.28578-100000@chaos.physics.uiowa.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kai-germaschewski@uiowa.edu
In-Reply-To: <Pine.LNX.4.44.0209291406410.28578-100000@chaos.physics.uiowa.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Kai Germaschewski <kai-germaschewski@uiowa.edu>
   Date: Sun, 29 Sep 2002 14:09:11 -0500 (CDT)

   On Sun, 29 Sep 2002, Jeff Garzik wrote:
   
   > Kai Germaschewski wrote:
   > > --- a/drivers/net/hamachi.c	Sun Sep 29 13:10:36 2002
   > > +++ b/drivers/net/hamachi.c	Sun Sep 29 13:10:36 2002
   > 
   > I would prefer to keep the code inside TX_CHECKSUM in hamachi.c, hoping 
   > somebody will complete it, not rip it out :)
   
   I didn't really rip out anything.

Jeff I think his patch is OK, please confirm.
